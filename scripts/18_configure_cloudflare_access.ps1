$ErrorActionPreference = "Stop"

$projectRoot = (Get-Location).Path
$renvironPath = Join-Path $projectRoot ".Renviron"
$wranglerPath = Join-Path $projectRoot "wrangler.jsonc"
$reviewerPath = Join-Path $projectRoot "cloudflare\reviewers.local.csv"

$tokenLine = Get-Content -LiteralPath $renvironPath |
  Where-Object { $_ -match '^CLOUDFLARE_API_TOKEN\s*=' } |
  Select-Object -First 1
if (-not $tokenLine) { throw "CLOUDFLARE_API_TOKEN is not configured." }
$token = ($tokenLine -replace '^CLOUDFLARE_API_TOKEN\s*=\s*', '').Trim().Trim('"').Trim("'")
$headers = @{ Authorization = "Bearer $token" }

$wrangler = Get-Content -Raw -LiteralPath $wranglerPath | ConvertFrom-Json
$accountId = $wrangler.account_id
$workerName = $wrangler.name
$accountSubdomain = "paris-ehis.workers.dev"
$appDomain = "$workerName.$accountSubdomain/api/*"
$base = "https://api.cloudflare.com/client/v4/accounts/$accountId/access"
$reviewers = Import-Csv -LiteralPath $reviewerPath |
  Where-Object { $_.active -eq "1" }
if (-not $reviewers) { throw "No active reviewers are configured." }

$organization = Invoke-RestMethod -Method Get -Uri "$base/organizations" -Headers $headers
$identityProviders = Invoke-RestMethod -Method Get -Uri "$base/identity_providers" -Headers $headers
$otpProvider = $identityProviders.result |
  Where-Object { $_.type -eq "onetimepin" } |
  Select-Object -First 1
if (-not $otpProvider) {
  $otpBody = @{
    name = "Código de un solo uso"
    type = "onetimepin"
    config = @{}
  } | ConvertTo-Json -Depth 6 -Compress
  $otpResponse = Invoke-RestMethod -Method Post -Uri "$base/identity_providers" `
    -Headers $headers -ContentType "application/json; charset=utf-8" `
    -Body ([Text.Encoding]::UTF8.GetBytes($otpBody))
  $otpProvider = $otpResponse.result
}

$apps = Invoke-RestMethod -Method Get -Uri "$base/apps" -Headers $headers
$app = $apps.result |
  Where-Object { $_.name -eq "PaRIS-EHIS private review API" } |
  Select-Object -First 1

$appBody = @{
  name = "PaRIS-EHIS private review API"
  domain = $appDomain
  type = "self_hosted"
  session_duration = "24h"
  app_launcher_visible = $false
  auto_redirect_to_identity = $true
  allowed_idps = @($otpProvider.id)
} | ConvertTo-Json -Depth 8 -Compress

if ($app) {
  $appResponse = Invoke-RestMethod -Method Put -Uri "$base/apps/$($app.id)" `
    -Headers $headers -ContentType "application/json; charset=utf-8" `
    -Body ([Text.Encoding]::UTF8.GetBytes($appBody))
} else {
  $appResponse = Invoke-RestMethod -Method Post -Uri "$base/apps" `
    -Headers $headers -ContentType "application/json; charset=utf-8" `
    -Body ([Text.Encoding]::UTF8.GetBytes($appBody))
}
$app = $appResponse.result

$policies = Invoke-RestMethod -Method Get -Uri "$base/apps/$($app.id)/policies" -Headers $headers
$policy = $policies.result |
  Where-Object { $_.name -eq "Authorized PaRIS-EHIS reviewers" } |
  Select-Object -First 1
$includeRules = @($reviewers | ForEach-Object {
  @{ email = @{ email = $_.email } }
})
$policyBody = @{
  name = "Authorized PaRIS-EHIS reviewers"
  precedence = 1
  decision = "allow"
  include = $includeRules
} | ConvertTo-Json -Depth 8 -Compress

if ($policy) {
  $policyResponse = Invoke-RestMethod -Method Put `
    -Uri "$base/apps/$($app.id)/policies/$($policy.id)" `
    -Headers $headers -ContentType "application/json; charset=utf-8" `
    -Body ([Text.Encoding]::UTF8.GetBytes($policyBody))
} else {
  $policyResponse = Invoke-RestMethod -Method Post `
    -Uri "$base/apps/$($app.id)/policies" `
    -Headers $headers -ContentType "application/json; charset=utf-8" `
    -Body ([Text.Encoding]::UTF8.GetBytes($policyBody))
}

Write-Output "ACCESS_APP_ID=$($app.id)"
Write-Output "ACCESS_AUD=$($app.aud)"
Write-Output "ACCESS_TEAM_DOMAIN=$($organization.result.auth_domain)"
Write-Output "ACCESS_IDP_TYPE=$($otpProvider.type)"
Write-Output "ACCESS_IDP_NAME=$($otpProvider.name)"
Write-Output "ACCESS_PROTECTED_DOMAIN=$($app.domain)"
Write-Output "ACCESS_POLICY_ID=$($policyResponse.result.id)"
Write-Output "AUTHORIZED_REVIEWERS=$($reviewers.Count)"
