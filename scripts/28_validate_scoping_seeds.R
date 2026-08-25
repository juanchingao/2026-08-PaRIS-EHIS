source("scripts/00_setup.R")

required <- c("dplyr", "readr", "stringr", "tidyr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

paths <- scoping_search_paths(project_paths)
seed_path <- file.path(project_root, "research", "scoping-review", "seed-references.csv")
output_path <- file.path(project_root, "research", "scoping-review", "seed-validation.csv")
seeds <- readr::read_csv(seed_path, show_col_types = FALSE, col_types = readr::cols(.default = "c"))
files <- list.files(paths$interim, pattern = "-records[.]csv$", full.names = TRUE)
records <- if (length(files)) dplyr::bind_rows(lapply(files, function(path) {
  readr::read_csv(path, show_col_types = FALSE, col_types = readr::cols(.default = "c"))
})) else empty_bibliographic_records()

databases <- c("PubMed/MEDLINE", "Scopus", "Embase")
identify_free_text_term <- function(record_rows) {
  found <- character()
  for (index in seq_len(nrow(record_rows))) {
    line <- record_rows$search_line[[index]]
    terms <- scopus_search_blocks(line)$method
    text <- tolower(paste(record_rows$title[[index]], record_rows$abstract[[index]]))
    matched <- vapply(terms, function(term) {
      clean <- tolower(gsub('"', "", term, fixed = TRUE))
      if (grepl("[*]$", clean)) {
        grepl(sub("[*]$", "", clean), text, fixed = TRUE)
      } else {
        grepl(clean, text, fixed = TRUE)
      }
    }, logical(1))
    if (any(matched)) {
      found <- c(found, paste0(record_rows$search_strategy_id[[index]], ":", terms[matched][[1]]))
    }
  }
  found <- unique(found)
  if (length(found)) paste(found, collapse = ";") else NA_character_
}

identify_controlled_term <- function(record_rows) {
  candidates <- c(
    "Data Integration", "Psychometrics", "Surveys and Questionnaires",
    "Health Surveys", "Epidemiologic Studies", "Patient Reported Outcome Measures"
  )
  present <- unique(unlist(strsplit(
    paste(stats::na.omit(record_rows$controlled_terms), collapse = ";"), ";",
    fixed = TRUE
  )))
  present <- trimws(present)
  matched <- candidates[tolower(candidates) %in% tolower(present)]
  if (length(matched)) paste(matched, collapse = ";") else NA_character_
}

validation <- tidyr::crossing(seeds, database = databases) |>
  dplyr::rowwise() |>
  dplyr::mutate(
    matched_indices = list(which(
      records$source_database == database & (
        nzchar(dplyr::coalesce(doi, "")) &
          normalize_bibliographic_doi(records$doi) == normalize_bibliographic_doi(doi) |
        nzchar(dplyr::coalesce(pmid, "")) & records$pmid == pmid
      )
    )),
    retrieved = length(matched_indices) > 0L,
    search_strategy_id = if (retrieved) paste(unique(
      records$search_strategy_id[matched_indices]
    ), collapse = ";") else NA_character_,
    retrieving_term = if (retrieved) identify_free_text_term(
      records[matched_indices, , drop = FALSE]
    ) else NA_character_,
    controlled_term = if (retrieved) identify_controlled_term(
      records[matched_indices, , drop = FALSE]
    ) else NA_character_,
    checked_at = as.character(Sys.Date()),
    observations = dplyr::case_when(
      retrieved & !is.na(retrieving_term) ~ "Matched by DOI or PMID in a real line execution; free-text attribution verified in title or abstract",
      retrieved & !is.na(controlled_term) ~ "Matched by DOI or PMID; retrieval attributable to controlled vocabulary or requires platform query explanation",
      retrieved ~ "Matched by DOI or PMID in a real line execution; term-level attribution requires database query explanation",
      !database %in% unique(records$source_database) ~ "Database not executed or no accessible results",
      TRUE ~ "Not recovered by the executed line results"
    )
  ) |>
  dplyr::ungroup() |>
  dplyr::select(
    seed_id, citation, doi, pmid, scopus_eid, embase_id,
    methodological_domain, expected_search_line, database, retrieved,
    retrieving_term, controlled_term, search_strategy_id, checked_at, observations
  )
readr::write_csv(validation, output_path, na = "")
seed_summary <- validation |>
  dplyr::count(database, retrieved, name = "seeds")
readr::write_csv(
  seed_summary,
  file.path(project_root, "research", "scoping-review", "reports",
            "seed-validation-summary.csv"),
  na = ""
)
print(seed_summary)
