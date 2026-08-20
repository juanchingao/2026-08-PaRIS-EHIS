source("scripts/00_setup.R")

required <- c("dplyr", "readr", "stringr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
records <- readr::read_csv(
  file.path(review_dir, "exports", "pubmed-results.csv"), show_col_types = FALSE
)

score_pattern <- function(text, pattern, points) {
  as.integer(stringr::str_detect(text, stringr::regex(pattern, ignore_case = TRUE))) * points
}

ranked <- records |>
  dplyr::mutate(
    text = paste(title, abstract),
    relevance_score =
      score_pattern(text, "retrospective (data )?harmoni[sz]", 8) +
      score_pattern(text, "data harmoni[sz]", 4) +
      score_pattern(text, "target(ed)? variable|common data model|dataschema", 4) +
      score_pattern(text, "measurement equivalence|measurement invariance", 4) +
      score_pattern(text, "scale linking|item response theory|common metric", 3) +
      score_pattern(text, "survey|cohort|epidemiolog", 2) +
      score_pattern(text, "patient.reported|PROM|PREM", 2) +
      score_pattern(text, "PaRIS|Patient.Reported Indicator Survey", 6) +
      score_pattern(text, "European Health Interview Survey", 6) +
      score_pattern(text, "guideline|framework|method|validation", 2),
    record_id = paste0("PMID-", pmid),
    source = "PubMed",
    stage = "title_abstract",
    decision = "PENDING_HUMAN_REVIEW",
    reason = "Machine-ranked candidate; no inclusion decision",
    reviewer = NA_character_,
    review_date = NA_character_,
    notes = paste0("Transparent relevance score: ", relevance_score)
  ) |>
  dplyr::arrange(dplyr::desc(relevance_score), dplyr::desc(year), title)

core_pmids <- c("27272186", "24257327", "33184054", "29511034", "26524232", "40791144", "42207414")
candidates <- ranked |>
  dplyr::filter(dplyr::row_number() <= 120 | pmid %in% core_pmids) |>
  dplyr::distinct(pmid, .keep_all = TRUE)

readr::write_csv(
  candidates,
  file.path(review_dir, "exports", "ranked-candidates.csv"), na = ""
)
readr::write_csv(
  candidates |>
    dplyr::select(record_id, title, year, source, stage, decision, reason,
                  reviewer, review_date, notes),
  file.path(review_dir, "candidate-screening.csv"), na = ""
)
message("Prepared ", nrow(candidates), " candidates for human review; no automated inclusions.")
