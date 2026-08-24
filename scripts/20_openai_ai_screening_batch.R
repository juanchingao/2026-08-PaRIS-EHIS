source("scripts/00_setup.R")

required <- c("curl", "httr2", "jsonlite", "readr", "yaml")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)
}

renviron_paths <- c(path.expand("~/.Renviron"), file.path(project_root, ".Renviron"))
invisible(lapply(renviron_paths[file.exists(renviron_paths)], readRenviron))

args <- commandArgs(trailingOnly = TRUE)
action <- if (length(args)) tolower(args[[1]]) else ""
if (!action %in% c("submit", "status", "download")) {
  stop(
    "Use: Rscript --vanilla scripts/20_openai_ai_screening_batch.R ",
    "submit|status|download",
    call. = FALSE
  )
}

config <- yaml::read_yaml(file.path(project_root, "config", "ai-screening.yml"))
model_override <- Sys.getenv("AI_SCREENING_MODEL", unset = "")
if (nzchar(model_override)) config$model <- model_override
output_dir <- file.path(project_paths$interim, "ai-screening", config$run_id)
request_path <- file.path(output_dir, "requests.jsonl")
manifest_path <- file.path(output_dir, "manifest.csv")
run_path <- file.path(output_dir, "run.json")
state_path <- file.path(output_dir, "batch-state.json")
result_path <- file.path(output_dir, "results.jsonl")
error_path <- file.path(output_dir, "errors.jsonl")

api_key <- Sys.getenv("OPENAI_API_KEY", unset = "")
if (!nzchar(api_key)) {
  stop("OPENAI_API_KEY is not configured in .Renviron.", call. = FALSE)
}

openai_request <- function(path) {
  httr2::request(paste0("https://api.openai.com", path)) |>
    httr2::req_auth_bearer_token(api_key) |>
    httr2::req_user_agent("PaRISEHIS-ai-screening/1.0")
}

perform_json <- function(request) {
  response <- request |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform()
  httr2::resp_check_status(response)
  httr2::resp_body_json(response, simplifyVector = FALSE)
}

zero_if_null <- function(value) if (is.null(value)) 0 else value

write_state <- function(batch) {
  state <- list(
    run_id = config$run_id,
    model = config$model,
    batch_id = batch$id,
    input_file_id = batch$input_file_id,
    status = batch$status,
    output_file_id = batch$output_file_id,
    error_file_id = batch$error_file_id,
    request_counts = batch$request_counts,
    created_at = batch$created_at,
    completed_at = batch$completed_at,
    updated_locally_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  )
  jsonlite::write_json(
    state, state_path, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null"
  )
  invisible(state)
}

if (action == "submit") {
  needed <- c(request_path, manifest_path, run_path)
  if (!all(file.exists(needed))) {
    stop("Prepare the local batch with script 19 before submitting it.", call. = FALSE)
  }
  manifest <- readr::read_csv(manifest_path, show_col_types = FALSE)
  has_restricted <- any(manifest$access_class == "RESTRICTED")
  explicit_authorisation <- identical(
    Sys.getenv("AI_SCREENING_ALLOW_RESTRICTED_UPLOAD", unset = ""), "YES"
  )
  if (isTRUE(config$require_explicit_restricted_upload_authorisation) &&
      has_restricted && !explicit_authorisation) {
    stop(
      "Restricted Scopus/Embase content is present. Set ",
      "AI_SCREENING_ALLOW_RESTRICTED_UPLOAD=YES only after confirming that ",
      "external processing is authorised.",
      call. = FALSE
    )
  }
  if (file.exists(state_path) &&
      !identical(Sys.getenv("AI_SCREENING_FORCE_RESUBMIT", unset = ""), "YES")) {
    stop(
      "A batch-state.json already exists. Refusing to submit a duplicate batch.",
      call. = FALSE
    )
  }

  uploaded_file <- openai_request("/v1/files") |>
    httr2::req_body_multipart(
      purpose = "batch",
      file = curl::form_file(request_path, type = "application/jsonl")
    ) |>
    perform_json()
  if (!identical(uploaded_file$purpose, "batch")) {
    stop("OpenAI did not register the input file for Batch.", call. = FALSE)
  }

  batch <- openai_request("/v1/batches") |>
    httr2::req_body_json(list(
      input_file_id = uploaded_file$id,
      endpoint = "/v1/responses",
      completion_window = config$completion_window,
      metadata = list(
        project = "PaRISEHIS",
        run_id = config$run_id,
        criteria_version = config$criteria_version
      )
    )) |>
    perform_json()
  write_state(batch)
  message("Batch submitted: ", batch$id)
  message("Status: ", batch$status)
  message("No model result has been imported into D1.")
}

if (action %in% c("status", "download")) {
  if (!file.exists(state_path)) {
    stop("batch-state.json is missing; submit the batch first.", call. = FALSE)
  }
  state <- jsonlite::read_json(state_path, simplifyVector = FALSE)
  batch <- openai_request(paste0("/v1/batches/", state$batch_id)) |>
    perform_json()
  write_state(batch)
  message("Batch: ", batch$id)
  message("Status: ", batch$status)
  if (!is.null(batch$request_counts)) {
    message(
      "Completed: ", zero_if_null(batch$request_counts$completed),
      "; failed: ", zero_if_null(batch$request_counts$failed),
      "; total: ", zero_if_null(batch$request_counts$total)
    )
  }

  if (action == "download") {
    if (!identical(batch$status, "completed") || is.null(batch$output_file_id)) {
      stop("The batch is not complete or has no output file.", call. = FALSE)
    }
    response <- openai_request(paste0("/v1/files/", batch$output_file_id, "/content")) |>
      httr2::req_retry(max_tries = 3) |>
      httr2::req_perform()
    httr2::resp_check_status(response)
    writeBin(httr2::resp_body_raw(response), result_path)
    if (!is.null(batch$error_file_id)) {
      error_response <- openai_request(paste0("/v1/files/", batch$error_file_id, "/content")) |>
        httr2::req_retry(max_tries = 3) |>
        httr2::req_perform()
      httr2::resp_check_status(error_response)
      writeBin(httr2::resp_body_raw(error_response), error_path)
    }
    message("Results downloaded to: ", result_path)
    message("No model result has been imported into D1.")
  }
}
