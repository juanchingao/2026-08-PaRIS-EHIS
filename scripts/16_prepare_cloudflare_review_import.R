source("scripts/00_setup.R")

required <- c("dplyr", "readr", "stringr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)
}

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")
reviewer_path <- file.path(project_root, "cloudflare", "reviewers.local.csv")
output_path <- file.path(project_paths$interim, "cloudflare-review-import.sql")

if (!file.exists(reviewer_path)) {
  stop("Missing private reviewer configuration: ", reviewer_path, call. = FALSE)
}

sql_value <- function(value) {
  if (length(value) == 0L || is.na(value) || !nzchar(as.character(value))) {
    return("NULL")
  }
  normalized <- gsub("[\r\n]+", " ", enc2utf8(as.character(value)))
  paste0("'", gsub("'", "''", normalized, fixed = TRUE), "'")
}

sql_integer <- function(value) {
  if (length(value) == 0L || is.na(value)) "NULL" else as.character(as.integer(value))
}

stage_value <- function(value) {
  ifelse(tolower(value) == "title_abstract", "TITLE_ABSTRACT", "TITLE_ONLY")
}

duplicate_target <- function(notes) {
  match <- stringr::str_match(dplyr::coalesce(notes, ""), "retained_record_id=([^; ]+)")
  match[, 2]
}

reviewers <- readr::read_csv(reviewer_path, show_col_types = FALSE)
required_reviewer_fields <- c("reviewer_id", "email", "display_name", "role", "active")
if (!all(required_reviewer_fields %in% names(reviewers))) {
  stop("Reviewer configuration has missing fields.", call. = FALSE)
}

pubmed_screening <- readr::read_csv(
  file.path(review_dir, "screening.csv"), show_col_types = FALSE
)
supplementary <- readr::read_csv(
  file.path(review_dir, "supplementary-screening.csv"), show_col_types = FALSE
)
pubmed_export <- readr::read_csv(
  file.path(export_dir, "pubmed-results.csv"), show_col_types = FALSE
)
scopus_export <- readr::read_csv(
  file.path(export_dir, "scopus-results.csv"), show_col_types = FALSE
)
embase_export <- readr::read_csv(
  file.path(export_dir, "embase-results.csv"), show_col_types = FALSE
)

pubmed_records <- pubmed_screening |>
  dplyr::left_join(
    pubmed_export |>
      dplyr::select(pmid, doi, abstract, journal, year, pubmed_url),
    by = "pmid"
  ) |>
  dplyr::transmute(
    record_id, public_reference_id = record_id, source_database = "PubMed",
    source_id = as.character(pmid), pmid = as.character(pmid), title,
    abstract_text = abstract, doi, journal, publication_year = year,
    source_url = pubmed_url, stage = stage_value(stage),
    access_class = "PUBLIC", duplicate_of = NA_character_,
    investigator_decision, confirmation_date,
    proposed_decision = dplyr::if_else(
      proposed_decision %in% c("INCLUDE", "BACKGROUND", "EXCLUDE"),
      proposed_decision, NA_character_
    ),
    proposed_reason
  )

scopus_metadata <- scopus_export |>
  dplyr::transmute(
    source_id = as.character(scopus_id),
    source_journal = publication,
    source_year = year
  ) |>
  dplyr::distinct(source_id, .keep_all = TRUE)

embase_metadata <- embase_export |>
  dplyr::transmute(
    source_id = as.character(embase_id), source_pmid = as.character(pmid),
    source_abstract = abstract, source_journal = journal,
    source_year = year, source_url = embase_url
  ) |>
  dplyr::distinct(source_id, .keep_all = TRUE)

supplementary_records <- supplementary |>
  dplyr::mutate(source_id = as.character(source_id)) |>
  dplyr::left_join(scopus_metadata, by = "source_id") |>
  dplyr::left_join(embase_metadata, by = "source_id", suffix = c("_scopus", "_embase")) |>
  dplyr::transmute(
    record_id, public_reference_id = NA_character_, source_database,
    source_id, pmid = dplyr::coalesce(as.character(pmid), source_pmid), title,
    abstract_text = source_abstract, doi,
    journal = dplyr::coalesce(source_journal_scopus, source_journal_embase),
    publication_year = dplyr::coalesce(source_year_scopus, source_year_embase),
    source_url, stage = stage_value(stage), access_class = "RESTRICTED",
    duplicate_of = duplicate_target(investigator_notes),
    investigator_decision, confirmation_date,
    proposed_decision = dplyr::case_when(
      low_proposed_decision %in% c("INCLUDE", "BACKGROUND", "EXCLUDE") ~ low_proposed_decision,
      proposed_decision %in% c("INCLUDE", "BACKGROUND", "EXCLUDE") ~ proposed_decision,
      TRUE ~ NA_character_
    ),
    proposed_reason = dplyr::coalesce(low_proposal_reason, proposed_reason)
  )

records <- dplyr::bind_rows(pubmed_records, supplementary_records)
if (anyDuplicated(records$record_id)) {
  stop("Duplicate record_id values in Cloudflare import.", call. = FALSE)
}
if (!all(records$investigator_decision %in% c("INCLUDE", "BACKGROUND", "EXCLUDE"))) {
  stop("Uncontrolled investigator decision in Cloudflare import.", call. = FALSE)
}
# Insert retained records before duplicate rows so foreign keys remain valid
# when the remote import is split into several transactions.
records <- records |>
  dplyr::arrange(!is.na(duplicate_of), record_id)

created_at <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
statements <- c("PRAGMA foreign_keys = ON;", "BEGIN TRANSACTION;")

for (i in seq_len(nrow(reviewers))) {
  reviewer <- reviewers[i, ]
  statements <- c(statements, paste0(
    "INSERT INTO reviewers (reviewer_id,email,display_name,role,active,created_at) VALUES (",
    paste(c(
      sql_value(reviewer$reviewer_id), sql_value(reviewer$email),
      sql_value(reviewer$display_name), sql_value(reviewer$role),
      sql_integer(reviewer$active), sql_value(created_at)
    ), collapse = ","),
    ") ON CONFLICT(reviewer_id) DO UPDATE SET email=excluded.email, ",
    "display_name=excluded.display_name, role=excluded.role, active=excluded.active;"
  ))
}

for (i in seq_len(nrow(records))) {
  record <- records[i, ]
  values <- c(
    sql_value(record$record_id), sql_value(record$public_reference_id),
    sql_value(record$source_database), sql_value(record$source_id),
    sql_value(record$pmid), sql_value(record$title),
    sql_value(record$abstract_text), sql_value(record$doi),
    sql_value(record$journal), sql_integer(record$publication_year),
    sql_value(record$source_url), sql_value(record$stage),
    sql_value(record$access_class), sql_value(record$duplicate_of),
    sql_value(created_at)
  )
  statements <- c(statements, paste0(
    "INSERT INTO review_records (record_id,public_reference_id,source_database,source_id,pmid,title,abstract_text,doi,journal,publication_year,source_url,stage,access_class,duplicate_of,created_at) VALUES (",
    paste(values, collapse = ","),
    ") ON CONFLICT(record_id) DO UPDATE SET public_reference_id=excluded.public_reference_id, ",
    "source_database=excluded.source_database, source_id=excluded.source_id, ",
    "pmid=excluded.pmid, title=excluded.title, abstract_text=excluded.abstract_text, ",
    "doi=excluded.doi, journal=excluded.journal, publication_year=excluded.publication_year, ",
    "source_url=excluded.source_url, stage=excluded.stage, ",
    "access_class=excluded.access_class, duplicate_of=excluded.duplicate_of;"
  ))
}

decision_rows <- records |>
  dplyr::transmute(
    record_id, reviewer_id = "JALR", decision = investigator_decision,
    notes = NA_character_,
    decided_at = dplyr::coalesce(as.character(confirmation_date), created_at)
  )
for (i in seq_len(nrow(decision_rows))) {
  decision <- decision_rows[i, ]
  statements <- c(statements, paste0(
    "INSERT INTO reviewer_decisions (record_id,reviewer_id,decision,reason_code,notes,decided_at,revision) VALUES (",
    paste(c(
      sql_value(decision$record_id), sql_value(decision$reviewer_id),
      sql_value(decision$decision), "NULL", sql_value(decision$notes),
      sql_value(decision$decided_at), "1"
    ), collapse = ","),
    ") ON CONFLICT(record_id,reviewer_id,revision) DO UPDATE SET ",
    "decision=excluded.decision, decided_at=excluded.decided_at;"
  ))
}

model_runs <- tibble::tribble(
  ~model_run_id, ~method, ~model_name, ~model_version, ~criteria_version,
  "codex-pubmed-2026-08-21", "LLM_TITLE_ABSTRACT", "Codex", "2026-08-21", "narrative-review-v0.2",
  "deterministic-supplementary-2026-08-23", "DETERMINISTIC_RULES", "priority-rules", "2026-08-23", "narrative-review-v0.2"
)
for (i in seq_len(nrow(model_runs))) {
  run <- model_runs[i, ]
  statements <- c(statements, paste0(
    "INSERT INTO model_runs (model_run_id,method,model_name,model_version,criteria_version,prompt_or_config_hash,created_at) VALUES (",
    paste(c(
      sql_value(run$model_run_id), sql_value(run$method), sql_value(run$model_name),
      sql_value(run$model_version), sql_value(run$criteria_version),
      sql_value("documented-in-repository"), sql_value(created_at)
    ), collapse = ","),
    ") ON CONFLICT(model_run_id) DO NOTHING;"
  ))
}

assessment_rows <- records |>
  dplyr::filter(!is.na(proposed_decision)) |>
  dplyr::mutate(
    model_run_id = dplyr::if_else(
      source_database == "PubMed",
      "codex-pubmed-2026-08-21",
      "deterministic-supplementary-2026-08-23"
    )
  )
for (i in seq_len(nrow(assessment_rows))) {
  assessment <- assessment_rows[i, ]
  statements <- c(statements, paste0(
    "INSERT INTO model_assessments (model_run_id,record_id,proposed_decision,rationale) VALUES (",
    paste(c(
      sql_value(assessment$model_run_id), sql_value(assessment$record_id),
      sql_value(assessment$proposed_decision), sql_value(assessment$proposed_reason)
    ), collapse = ","),
    ") ON CONFLICT(model_run_id,record_id) DO UPDATE SET ",
    "proposed_decision=excluded.proposed_decision, rationale=excluded.rationale;"
  ))
}

statements <- c(statements, "COMMIT;")
writeLines(enc2utf8(statements), output_path, useBytes = TRUE)

message("Private D1 import written to: ", output_path)
message("Reviewers: ", nrow(reviewers))
message("Records: ", nrow(records), " (effective: ", sum(is.na(records$duplicate_of)), ")")
message("JALR decisions: ", nrow(decision_rows))
message("Model assessments: ", nrow(assessment_rows))
