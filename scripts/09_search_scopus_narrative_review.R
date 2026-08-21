source("scripts/00_setup.R")

required <- c("dplyr", "readr", "scopusflow", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

# In isolated/non-interactive runs R may not read the user Renviron. Read only
# the standard locations; never print or persist their contents.
renviron_paths <- c(path.expand("~/.Renviron"), file.path(project_root, ".Renviron"))
invisible(lapply(renviron_paths[file.exists(renviron_paths)], readRenviron))
if (!scopusflow::scopus_has_key()) stop("SCOPUS_API_KEY is not available.", call. = FALSE)

queries <- c(
  `NR-SCOPUS-01` = paste0(
    'TITLE-ABS-KEY(("data harmonization" OR "data harmonisation" OR ',
    '"retrospective harmonization" OR "retrospective harmonisation") ',
    'AND (survey* OR cohort* OR epidemiolog* OR health))'
  ),
  `NR-SCOPUS-02` = paste0(
    'TITLE-ABS-KEY(("measurement equivalence" OR "measurement invariance" OR ',
    '"questionnaire harmonization" OR "questionnaire harmonisation" OR ',
    '"common metric" OR "scale linking") AND ',
    '(health OR "patient reported" OR population))'
  ),
  `NR-SCOPUS-03` = paste0(
    'TITLE-ABS-KEY(("Patient-Reported Indicator Surveys" OR ',
    '"Patient-Reported Indicator Survey" OR "European Health Interview Survey") ',
    'AND (harmon* OR comparab* OR method* OR valid*))'
  )
)

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")
dir.create(export_dir, recursive = TRUE, showWarnings = FALSE)

counts <- lapply(names(queries), function(id) {
  result <- scopusflow::scopus_count(queries[[id]])
  tibble::tibble(
    strategy_id = id,
    database = "Scopus",
    retrieval_date = as.character(Sys.Date()),
    query = queries[[id]],
    records_available = as.integer(result),
    retrieval_cap = 500L
  )
}) |>
  dplyr::bind_rows()

readr::write_csv(counts, file.path(export_dir, "scopus-query-counts.csv"), na = "")
print(counts |> dplyr::select(strategy_id, records_available, retrieval_cap))

if ("--count-only" %in% commandArgs(trailingOnly = TRUE)) quit(save = "no")

sets <- lapply(names(queries), function(id) {
  records <- scopusflow::scopus_fetch(
    queries[[id]], max_results = 500, view = "STANDARD", verbose = TRUE
  )
  records$strategy_id <- id
  records
})
names(sets) <- names(queries)

scopus_results <- dplyr::bind_rows(sets) |>
  dplyr::mutate(
    doi_normalized = tolower(sub(
      "^https?://(dx[.])?doi[.]org/", "", dplyr::coalesce(doi, "")
    )),
    title_normalized = tolower(trimws(gsub(
      "[[:space:]]+", " ", gsub("[^[:alnum:]]+", " ", dplyr::coalesce(title, ""))
    )))
  )

readr::write_csv(scopus_results, file.path(export_dir, "scopus-results.csv"), na = "")

pubmed <- readr::read_csv(
  file.path(export_dir, "pubmed-results.csv"), show_col_types = FALSE
) |>
  dplyr::mutate(
    doi_normalized = tolower(dplyr::coalesce(doi_normalized, "")),
    title_normalized = tolower(trimws(gsub(
      "[[:space:]]+", " ", gsub("[^[:alnum:]]+", " ", dplyr::coalesce(title, ""))
    )))
  )

scopus_unique <- scopus_results |>
  dplyr::arrange(strategy_id, entry_number) |>
  dplyr::distinct(scopus_id, .keep_all = TRUE) |>
  dplyr::mutate(
    matched_pubmed = (nzchar(doi_normalized) & doi_normalized %in% pubmed$doi_normalized) |
      title_normalized %in% pubmed$title_normalized,
    match_basis = dplyr::case_when(
      nzchar(doi_normalized) & doi_normalized %in% pubmed$doi_normalized ~ "DOI",
      title_normalized %in% pubmed$title_normalized ~ "TITLE",
      TRUE ~ "NONE"
    )
  )

readr::write_csv(
  scopus_unique,
  file.path(export_dir, "scopus-pubmed-comparison.csv"),
  na = ""
)

summary <- tibble::tibble(
  metric = c(
    "pubmed_unique", "scopus_rows_retrieved", "scopus_unique",
    "scopus_matched_pubmed", "scopus_not_in_pubmed"
  ),
  records = c(
    nrow(pubmed), nrow(scopus_results), nrow(scopus_unique),
    sum(scopus_unique$matched_pubmed), sum(!scopus_unique$matched_pubmed)
  )
)
readr::write_csv(summary, file.path(export_dir, "scopus-comparison-summary.csv"), na = "")
print(summary)
