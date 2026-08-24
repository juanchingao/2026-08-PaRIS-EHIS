source("scripts/00_setup.R")
source("R/bibliographic_deduplication.R")

required <- c("dplyr", "readr", "scopusflow", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

# In isolated/non-interactive runs R may not read the user Renviron. Read only
# the standard locations; never print or persist their contents.
renviron_paths <- c(path.expand("~/.Renviron"), file.path(project_root, ".Renviron"))
invisible(lapply(renviron_paths[file.exists(renviron_paths)], readRenviron))
if (!scopusflow::scopus_has_key()) stop("SCOPUS_API_KEY is not available.", call. = FALSE)

query_terms <- list(
  `NR-SCOPUS-01` = c(
    "data harmonization", "data harmonisation",
    "retrospective harmonization", "retrospective harmonisation"
  ),
  `NR-SCOPUS-02` = c(
    "measurement equivalence", "measurement invariance",
    "questionnaire harmonization", "questionnaire harmonisation",
    "common metric", "scale linking"
  ),
  `NR-SCOPUS-03` = c(
    "Patient-Reported Indicator Surveys", "Patient-Reported Indicator Survey",
    "European Health Interview Survey"
  )
)

objectives <- c(
  `NR-SCOPUS-01` = "Retrospective harmonisation methods",
  `NR-SCOPUS-02` = "Measurement and questionnaire equivalence",
  `NR-SCOPUS-03` = "PaRIS and EHIS applications"
)

build_subquery <- function(term, current_strategy_id) {
  if (current_strategy_id == "NR-SCOPUS-01") {
    return(paste0(
      'TITLE-ABS-KEY("', term, '" AND (survey* OR cohort* OR epidemiolog*) AND ',
      '(method* OR framework* OR guideline* OR protocol* OR comparab* OR valid*))'
    ))
  }
  if (current_strategy_id == "NR-SCOPUS-02") {
    return(paste0(
      'TITLE("', term, '") AND TITLE-ABS-KEY((survey* OR "general population" OR ',
      'population-based OR epidemiolog*) AND (health OR "patient reported"))'
    ))
  }
  paste0(
    'TITLE-ABS-KEY("', term, '" AND (harmon* OR comparab* OR method* OR valid*))'
  )
}

subqueries <- dplyr::bind_rows(lapply(names(query_terms), function(strategy_id) {
  current_id <- strategy_id
  terms <- query_terms[[strategy_id]]
  tibble::tibble(
    strategy_id = current_id,
    subquery_id = paste0(current_id, "-", sprintf("%02d", seq_along(terms))),
    query = vapply(
      terms, build_subquery, character(1), current_strategy_id = current_id
    )
  )
}))

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")
dir.create(export_dir, recursive = TRUE, showWarnings = FALSE)

max_results_per_query <- 1000L

counts <- lapply(seq_len(nrow(subqueries)), function(i) {
  result <- scopusflow::scopus_count(subqueries$query[[i]])
  tibble::tibble(
    strategy_id = subqueries$strategy_id[[i]],
    subquery_id = subqueries$subquery_id[[i]],
    database = "Scopus",
    objective = unname(objectives[subqueries$strategy_id[[i]]]),
    retrieval_date = as.character(Sys.Date()),
    query = subqueries$query[[i]],
    filters = "No date or language filters; STANDARD view; page size 25",
    records_available = as.integer(result),
    retrieval_cap = max_results_per_query
  )
}) |>
  dplyr::bind_rows()

readr::write_csv(counts, file.path(export_dir, "scopus-query-counts.csv"), na = "")
print(counts |> dplyr::select(strategy_id, subquery_id, records_available))

if ("--count-only" %in% commandArgs(trailingOnly = TRUE)) quit(save = "no")

retrievable <- counts |>
  dplyr::filter(records_available > 0L)

sets <- lapply(seq_len(nrow(retrievable)), function(i) {
  records <- scopusflow::scopus_fetch(
    retrievable$query[[i]], max_results = retrievable$records_available[[i]],
    view = "STANDARD", page_size = 25L, verbose = TRUE
  )
  records$strategy_id <- retrievable$strategy_id[[i]]
  records$subquery_id <- retrievable$subquery_id[[i]]
  records
})

scopus_results <- dplyr::bind_rows(sets)

readr::write_csv(scopus_results, file.path(export_dir, "scopus-results.csv"), na = "")

pubmed <- readr::read_csv(
  file.path(export_dir, "pubmed-results.csv"), show_col_types = FALSE
)

scopus_unique <- scopus_results |>
  dplyr::arrange(strategy_id, entry_number) |>
  dplyr::group_by(scopus_id) |>
  dplyr::summarise(
    strategy_id = paste(sort(unique(strategy_id)), collapse = ";"),
    subquery_id = paste(sort(unique(subquery_id)), collapse = ";"),
    dplyr::across(-c(strategy_id, subquery_id), dplyr::first),
    .groups = "drop"
  ) |>
  match_scopus_to_pubmed(pubmed)

readr::write_csv(
  scopus_unique,
  file.path(export_dir, "scopus-pubmed-comparison.csv"),
  na = ""
)
readr::write_csv(
  dplyr::filter(scopus_unique, !matched_pubmed),
  file.path(export_dir, "scopus-not-in-pubmed.csv"),
  na = ""
)

strategy_summary <- dplyr::bind_rows(lapply(names(query_terms), function(id) {
  members <- grepl(id, scopus_unique$strategy_id, fixed = TRUE)
  tibble::tibble(
    strategy_id = id,
    scopus_unique = sum(members),
    matched_pubmed = sum(members & scopus_unique$matched_pubmed),
    not_in_pubmed = sum(members & !scopus_unique$matched_pubmed)
  )
}))
readr::write_csv(
  strategy_summary,
  file.path(export_dir, "scopus-strategy-summary.csv"),
  na = ""
)

summary <- tibble::tibble(
  metric = c(
    "pubmed_unique", "scopus_rows_retrieved", "scopus_unique",
    "scopus_matched_pubmed", "scopus_not_in_pubmed", "combined_unique"
  ),
  records = c(
    nrow(pubmed), nrow(scopus_results), nrow(scopus_unique),
    sum(scopus_unique$matched_pubmed), sum(!scopus_unique$matched_pubmed),
    nrow(pubmed) + sum(!scopus_unique$matched_pubmed)
  )
)
readr::write_csv(summary, file.path(export_dir, "scopus-comparison-summary.csv"), na = "")
print(summary)
