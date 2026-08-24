param(
  [string]$SqlPath = "data/interim/cloudflare-review-import.sql",
  [int]$BatchSizeBytes = 45000
)

$ErrorActionPreference = "Stop"

$projectRoot = (Get-Location).Path
$wranglerConfigPath = Join-Path $projectRoot "wrangler.jsonc"
$resolvedSqlPath = (Resolve-Path -LiteralPath (Join-Path $projectRoot $SqlPath)).Path
$oauthConfigPath = Join-Path $env:APPDATA "xdg.config\.wrangler\config\default.toml"

if (-not (Test-Path -LiteralPath $wranglerConfigPath)) {
  throw "wrangler.jsonc is not available."
}
if (-not (Test-Path -LiteralPath $oauthConfigPath)) {
  throw "Wrangler OAuth configuration is not available."
}

$wranglerConfig = Get-Content -Raw -LiteralPath $wranglerConfigPath | ConvertFrom-Json
$accountId = $wranglerConfig.account_id
$databaseId = $wranglerConfig.d1_databases[0].database_id
$databaseName = $wranglerConfig.d1_databases[0].database_name

$tokenLine = Get-Content -LiteralPath $oauthConfigPath |
  Where-Object { $_ -match '^oauth_token\s*=' } |
  Select-Object -First 1
if (-not $tokenLine) {
  throw "Wrangler OAuth token is not available."
}
$oauthToken = ($tokenLine -replace '^oauth_token\s*=\s*', '').Trim().Trim('"')
$headers = @{ Authorization = "Bearer $oauthToken" }
$uri = "https://api.cloudflare.com/client/v4/accounts/$accountId/d1/database/$databaseId/query"

$statements = Get-Content -LiteralPath $resolvedSqlPath -Encoding UTF8 |
  Where-Object {
    $_ -and
    $_ -notmatch '^PRAGMA foreign_keys' -and
    $_ -ne 'BEGIN TRANSACTION;' -and
    $_ -ne 'COMMIT;'
  }

$batches = [System.Collections.Generic.List[string]]::new()
$current = [System.Text.StringBuilder]::new()
foreach ($statement in $statements) {
  $statementBytes = [System.Text.Encoding]::UTF8.GetByteCount($statement)
  if ($statementBytes -gt $BatchSizeBytes) {
    throw "A SQL statement exceeds the configured D1 batch size."
  }
  $currentBytes = [System.Text.Encoding]::UTF8.GetByteCount($current.ToString())
  if ($current.Length -gt 0 -and ($currentBytes + $statementBytes) -gt $BatchSizeBytes) {
    $batches.Add($current.ToString())
    $null = $current.Clear()
  }
  $null = $current.AppendLine($statement)
}
if ($current.Length -gt 0) {
  $batches.Add($current.ToString())
}

Write-Output "Importing $($statements.Count) statements in $($batches.Count) batches to $databaseName."
for ($i = 0; $i -lt $batches.Count; $i++) {
  $body = @{ sql = $batches[$i] } | ConvertTo-Json -Compress
  $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
  $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers `
    -ContentType "application/json; charset=utf-8" -Body $bodyBytes
  if (-not $response.success) {
    throw "D1 rejected batch $($i + 1)."
  }
  Write-Output "Batch $($i + 1)/$($batches.Count) imported."
}

$verificationBody = @{
  sql = @"
SELECT source_database, COUNT(*) AS records,
  SUM(CASE WHEN duplicate_of IS NULL THEN 1 ELSE 0 END) AS effective
FROM review_records GROUP BY source_database ORDER BY source_database;
SELECT reviewer_id, email, active FROM reviewers ORDER BY reviewer_id;
SELECT COUNT(*) AS decisions FROM reviewer_decisions;
SELECT COUNT(*) AS assessments FROM model_assessments;
"@
} | ConvertTo-Json -Compress
$verification = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers `
  -ContentType "application/json; charset=utf-8" `
  -Body ([System.Text.Encoding]::UTF8.GetBytes($verificationBody))

if (-not $verification.success) {
  throw "D1 verification query failed."
}

$verification.result[0].results | ForEach-Object {
  Write-Output "SOURCE=$($_.source_database) RECORDS=$($_.records) EFFECTIVE=$($_.effective)"
}
$verification.result[1].results | ForEach-Object {
  Write-Output "REVIEWER=$($_.reviewer_id) EMAIL=$($_.email) ACTIVE=$($_.active)"
}
Write-Output "DECISIONS=$($verification.result[2].results[0].decisions)"
Write-Output "ASSESSMENTS=$($verification.result[3].results[0].assessments)"
