source("scripts/00_setup.R")

required <- c("digest", "dplyr", "jsonlite", "readr", "stringr", "yaml")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)
}

config_path <- file.path(project_root, "config", "ai-screening.yml")
config <- yaml::read_yaml(config_path)
model_override <- Sys.getenv("AI_SCREENING_MODEL", unset = "")
if (nzchar(model_override)) config$model <- model_override

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")
prompt_path <- file.path(project_root, config$prompt_path)
schema_path <- file.path(project_root, config$schema_path)
output_dir <- file.path(project_paths$interim, "ai-screening", config$run_id)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

prompt <- paste(readLines(prompt_path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
response_schema <- jsonlite::read_json(schema_path, simplifyVector = FALSE)
prompt_hash <- ai_screening_hash(prompt)
config_hash <- ai_screening_hash(paste(readLines(
  config_path, encoding = "UTF-8", warn = FALSE
), collapse = "\n"))

pubmed_screening <- readr::read_csv(
  file.path(review_dir, "screening.csv"), show_col_types = FALSE
)
pubmed_export <- readr::read_csv(
  file.path(export_dir, "pubmed-results.csv"), show_col_types = FALSE
)
supplementary <- readr::read_csv(
  file.path(review_dir, "supplementary-screening.csv"), show_col_types = FALSE
)
embase_export <- readr::read_csv(
  file.path(export_dir, "embase-results.csv"), show_col_types = FALSE
)

pubmed_records <- pubmed_screening |>
  dplyr::mutate(pmid = as.character(pmid)) |>
  dplyr::select(record_id, pmid, title, stage) |>
  dplyr::left_join(
    pubmed_export |>
      dplyr::transmute(
        pmid = as.character(pmid), source_id = as.character(pmid),
        abstract_text = abstract
      ),
    by = "pmid"
  ) |>
  dplyr::transmute(
    record_id, source_database = "PubMed", source_id, title,
    abstract_text, stage = toupper(stage), access_class = "PUBLIC"
  )

embase_abstracts <- embase_export |>
  dplyr::transmute(
    source_id = as.character(embase_id), abstract_text = abstract
  ) |>
  dplyr::distinct(source_id, .keep_all = TRUE)

duplicate_target <- function(notes) {
  match <- stringr::str_match(
    dplyr::coalesce(notes, ""), "retained_record_id=([^; ]+)"
  )
  match[, 2]
}

supplementary_records <- supplementary |>
  dplyr::mutate(
    source_id = as.character(source_id),
    duplicate_of = duplicate_target(investigator_notes)
  ) |>
  dplyr::filter(is.na(duplicate_of)) |>
  dplyr::select(record_id, source_database, source_id, title, stage) |>
  dplyr::left_join(embase_abstracts, by = "source_id") |>
  dplyr::mutate(
    abstract_text = dplyr::if_else(
      source_database == "Embase", abstract_text, NA_character_
    ),
    stage = toupper(stage),
    access_class = "RESTRICTED"
  ) |>
  dplyr::select(
    record_id, source_database, source_id, title,
    abstract_text, stage, access_class
  )

records <- dplyr::bind_rows(pubmed_records, supplementary_records) |>
  dplyr::arrange(record_id)
validate_ai_screening_records(records)

request_lines <- vapply(seq_len(nrow(records)), function(index) {
  request <- build_openai_screening_request(
    records[index, ], prompt, response_schema, config$model,
    config$reasoning_effort, config$max_output_tokens
  )
  jsonlite::toJSON(
    request, auto_unbox = TRUE, null = "null", na = "null", digits = NA
  )
}, character(1))

request_path <- file.path(output_dir, "requests.jsonl")
manifest_path <- file.path(output_dir, "manifest.csv")
run_path <- file.path(output_dir, "run.json")
writeLines(enc2utf8(request_lines), request_path, useBytes = TRUE)

manifest <- records |>
  dplyr::transmute(
    record_id, source_database, stage, access_class,
    input_hash = vapply(
      seq_len(dplyr::n()),
      function(index) ai_screening_input_hash(records[index, ]),
      character(1)
    )
  )
readr::write_csv(manifest, manifest_path, na = "")

git_commit <- tryCatch(
  system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE)[1],
  error = function(...) NA_character_
)
git_status <- tryCatch(
  system2("git", c("status", "--short"), stdout = TRUE, stderr = FALSE),
  error = function(...) character()
)
run <- list(
  run_id = config$run_id,
  provider = config$provider,
  model = config$model,
  method = config$method,
  criteria_version = config$criteria_version,
  reasoning_effort = config$reasoning_effort,
  max_output_tokens = config$max_output_tokens,
  training_cutoff = config$training_cutoff,
  completion_window = config$completion_window,
  prompt_hash = prompt_hash,
  config_hash = config_hash,
  request_file_hash = ai_screening_hash(paste(request_lines, collapse = "\n")),
  git_commit = git_commit,
  dirty_worktree = length(git_status) > 0L,
  prepared_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  record_count = nrow(records),
  title_abstract_count = sum(records$stage == "TITLE_ABSTRACT"),
  title_only_count = sum(records$stage == "TITLE_ONLY"),
  restricted_record_count = sum(records$access_class == "RESTRICTED"),
  human_decision_fields_excluded = TRUE,
  external_upload_performed = FALSE
)
jsonlite::write_json(run, run_path, auto_unbox = TRUE, pretty = TRUE, na = "null")

message("AI screening batch prepared locally: ", request_path)
message("Records: ", nrow(records))
message("Title + abstract: ", run$title_abstract_count)
message("Title only: ", run$title_only_count)
message("Restricted records: ", run$restricted_record_count)
message("External upload performed: FALSE")
