source("scripts/00_setup.R")

required <- c("dplyr", "jsonlite", "readr", "tibble", "yaml")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)
}

config <- yaml::read_yaml(file.path(project_root, "config", "ai-screening.yml"))
model_override <- Sys.getenv("AI_SCREENING_MODEL", unset = "")
if (nzchar(model_override)) config$model <- model_override
output_dir <- file.path(project_paths$interim, "ai-screening", config$run_id)
manifest_path <- file.path(output_dir, "manifest.csv")
run_path <- file.path(output_dir, "run.json")
state_path <- file.path(output_dir, "batch-state.json")
result_path <- file.path(output_dir, "results.jsonl")
sql_path <- file.path(output_dir, "model-assessments.sql")
summary_path <- file.path(output_dir, "assessment-summary.csv")

needed <- c(manifest_path, run_path, state_path, result_path)
if (!all(file.exists(needed))) {
  stop(
    "Manifest, run metadata, batch state and results are all required before import.",
    call. = FALSE
  )
}

manifest <- readr::read_csv(manifest_path, show_col_types = FALSE)
run <- jsonlite::read_json(run_path, simplifyVector = FALSE)
state <- jsonlite::read_json(state_path, simplifyVector = FALSE)
result_lines <- readLines(result_path, encoding = "UTF-8", warn = FALSE)
if (!length(result_lines)) stop("The OpenAI result file is empty.", call. = FALSE)

parsed <- lapply(seq_along(result_lines), function(index) {
  tryCatch(
    parse_openai_screening_batch_line(result_lines[[index]]),
    error = function(error) {
      stop("Invalid AI result on line ", index, ": ", conditionMessage(error), call. = FALSE)
    }
  )
})
record_ids <- vapply(parsed, `[[`, character(1), "custom_id")
if (anyDuplicated(record_ids)) stop("AI results contain duplicate custom_id values.", call. = FALSE)
if (!setequal(record_ids, manifest$record_id) || length(record_ids) != nrow(manifest)) {
  stop("AI results do not match the frozen input manifest.", call. = FALSE)
}

manifest_index <- match(record_ids, manifest$record_id)
for (index in seq_along(parsed)) {
  expected_stage <- manifest$stage[[manifest_index[[index]]]]
  if (!identical(parsed[[index]]$assessment$evidence_basis, expected_stage)) {
    stop("AI evidence_basis does not match the manifest for ", record_ids[[index]], ".", call. = FALSE)
  }
}

sql_value <- function(value) {
  if (length(value) == 0L || is.null(value) || is.na(value) || !nzchar(as.character(value))) {
    return("NULL")
  }
  normalized <- gsub("[\r\n]+", " ", enc2utf8(as.character(value)))
  paste0("'", gsub("'", "''", normalized, fixed = TRUE), "'")
}

completed_at <- if (!is.null(state$completed_at)) {
  format(as.POSIXct(state$completed_at, origin = "1970-01-01", tz = "UTC"),
         "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
} else {
  format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

statements <- c(
  "PRAGMA foreign_keys = ON;",
  "BEGIN TRANSACTION;",
  paste0(
    "INSERT INTO model_runs (model_run_id,method,model_name,model_version,criteria_version,",
    "prompt_or_config_hash,training_cutoff,created_at) VALUES (",
    paste(c(
      sql_value(config$run_id), sql_value(config$method), sql_value(config$provider),
      sql_value(config$model), sql_value(config$criteria_version),
      sql_value(run$prompt_hash), sql_value(config$training_cutoff),
      sql_value(completed_at)
    ), collapse = ","),
    ") ON CONFLICT(model_run_id) DO NOTHING;"
  )
)

summary_rows <- vector("list", length(parsed))
for (index in seq_along(parsed)) {
  assessment <- parsed[[index]]$assessment
  manifest_row <- manifest[manifest_index[[index]], ]
  rationale <- jsonlite::toJSON(list(
    schema_version = config$criteria_version,
    prompt_hash = run$prompt_hash,
    input_hash = manifest_row$input_hash,
    source_database = manifest_row$source_database,
    evidence_basis = manifest_row$stage,
    assessment = assessment
  ), auto_unbox = TRUE, null = "null", na = "null")
  statements <- c(statements, paste0(
    "INSERT INTO model_assessments (model_run_id,record_id,proposed_decision,",
    "relevance_probability,rationale) VALUES (",
    paste(c(
      sql_value(config$run_id), sql_value(record_ids[[index]]),
      sql_value(assessment$decision), "NULL", sql_value(rationale)
    ), collapse = ","),
    ") ON CONFLICT(model_run_id,record_id) DO NOTHING;"
  ))
  summary_rows[[index]] <- tibble::tibble(
    record_id = record_ids[[index]],
    source_database = manifest_row$source_database,
    evidence_basis = assessment$evidence_basis,
    decision = assessment$decision,
    reason_code = assessment$primary_reason_code,
    certainty = assessment$certainty,
    needs_human_review = assessment$needs_human_review,
    input_hash = manifest_row$input_hash
  )
}
statements <- c(statements, "COMMIT;")
writeLines(enc2utf8(statements), sql_path, useBytes = TRUE)
summary <- dplyr::bind_rows(summary_rows) |>
  dplyr::arrange(record_id)
readr::write_csv(summary, summary_path, na = "")

message("Frozen D1 import prepared: ", sql_path)
message("Assessments validated: ", nrow(summary))
message("This script did not modify D1.")
