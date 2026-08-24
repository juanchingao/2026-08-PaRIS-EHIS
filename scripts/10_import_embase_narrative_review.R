source("scripts/00_setup.R")
source("R/bibliographic_deduplication.R")
source("R/ris_import.R")

required <- c("dplyr", "readr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")
manifest <- readr::read_csv(
  file.path(review_dir, "embase-export-manifest.csv"), show_col_types = FALSE
)

raw_sets <- lapply(seq_len(nrow(manifest)), function(i) {
  path <- file.path(export_dir, manifest$source_file[[i]])
  if (!file.exists(path)) stop("Missing Embase export: ", path, call. = FALSE)
  records <- parse_ris_file(path, manifest$strategy_id[[i]])
  if (nrow(records) != manifest$records_exported[[i]]) {
    stop("Unexpected record count in ", basename(path), call. = FALSE)
  }
  records
})
embase_rows <- dplyr::bind_rows(raw_sets) |>
  dplyr::mutate(
    doi_normalized = normalize_bibliographic_doi(doi),
    title_normalized = normalize_bibliographic_title(title),
    pmid = dplyr::coalesce(pmid, ""),
    embase_id = dplyr::coalesce(embase_id, ""),
    dedup_key = dplyr::case_when(
      nzchar(embase_id) ~ paste0("embase:", embase_id),
      nzchar(doi_normalized) ~ paste0("doi:", doi_normalized),
      nzchar(pmid) ~ paste0("pmid:", pmid),
      nzchar(title_normalized) ~ paste0("title:", title_normalized),
      TRUE ~ paste0("row:", dplyr::row_number())
    )
  )
readr::write_csv(embase_rows, file.path(export_dir, "embase-results.csv"), na = "")

embase_unique <- embase_rows |>
  dplyr::group_by(dedup_key) |>
  dplyr::summarise(
    strategy_id = paste(sort(unique(strategy_id)), collapse = ";"),
    source_file = paste(sort(unique(source_file)), collapse = ";"),
    dplyr::across(-c(strategy_id, source_file), dplyr::first),
    .groups = "drop"
  ) |>
  dplyr::select(-dedup_key)

pubmed <- readr::read_csv(
  file.path(export_dir, "pubmed-results.csv"), show_col_types = FALSE
) |>
  dplyr::mutate(
    pmid = dplyr::coalesce(as.character(pmid), ""),
    doi_normalized = normalize_bibliographic_doi(doi),
    title_normalized = normalize_bibliographic_title(title)
  )
scopus <- readr::read_csv(
  file.path(export_dir, "scopus-pubmed-comparison.csv"), show_col_types = FALSE
) |>
  dplyr::mutate(
    doi_normalized = normalize_bibliographic_doi(doi),
    title_normalized = normalize_bibliographic_title(title)
  )

embase_unique <- embase_unique |>
  dplyr::mutate(
    matched_pubmed =
      (nzchar(pmid) & pmid %in% pubmed$pmid) |
      (nzchar(doi_normalized) & doi_normalized %in% pubmed$doi_normalized) |
      (nzchar(title_normalized) & title_normalized %in% pubmed$title_normalized),
    matched_scopus =
      (nzchar(doi_normalized) & doi_normalized %in% scopus$doi_normalized) |
      (nzchar(title_normalized) & title_normalized %in% scopus$title_normalized),
    match_basis_pubmed = dplyr::case_when(
      nzchar(pmid) & pmid %in% pubmed$pmid ~ "PMID",
      nzchar(doi_normalized) & doi_normalized %in% pubmed$doi_normalized ~ "DOI",
      nzchar(title_normalized) & title_normalized %in% pubmed$title_normalized ~ "TITLE",
      TRUE ~ "NONE"
    ),
    match_basis_scopus = dplyr::case_when(
      nzchar(doi_normalized) & doi_normalized %in% scopus$doi_normalized ~ "DOI",
      nzchar(title_normalized) & title_normalized %in% scopus$title_normalized ~ "TITLE",
      TRUE ~ "NONE"
    ),
    new_vs_pubmed_scopus = !matched_pubmed & !matched_scopus
  )

readr::write_csv(embase_unique, file.path(export_dir, "embase-unique.csv"), na = "")
readr::write_csv(
  dplyr::filter(embase_unique, new_vs_pubmed_scopus),
  file.path(export_dir, "embase-not-in-pubmed-scopus.csv"), na = ""
)

summary <- tibble::tibble(
  metric = c(
    "embase_rows_imported", "embase_unique", "embase_matched_pubmed",
    "embase_matched_scopus", "embase_matched_either", "embase_new"
  ),
  records = c(
    nrow(embase_rows), nrow(embase_unique), sum(embase_unique$matched_pubmed),
    sum(embase_unique$matched_scopus),
    sum(embase_unique$matched_pubmed | embase_unique$matched_scopus),
    sum(embase_unique$new_vs_pubmed_scopus)
  )
)
readr::write_csv(summary, file.path(export_dir, "embase-comparison-summary.csv"), na = "")

strategy_summary <- dplyr::bind_rows(lapply(unique(manifest$strategy_id), function(id) {
  records <- embase_unique
  members <- grepl(id, embase_unique$strategy_id, fixed = TRUE)
  tibble::tibble(
    strategy_id = id,
    embase_unique = sum(members),
    matched_pubmed_or_scopus = sum(
      members & (records$matched_pubmed | records$matched_scopus)
    ),
    new_vs_pubmed_scopus = sum(members & records$new_vs_pubmed_scopus)
  )
}))
readr::write_csv(
  strategy_summary, file.path(export_dir, "embase-strategy-summary.csv"), na = ""
)

scopus_summary <- readr::read_csv(
  file.path(export_dir, "scopus-comparison-summary.csv"), show_col_types = FALSE
)
value <- function(metric) scopus_summary$records[scopus_summary$metric == metric]
multidatabase_summary <- tibble::tibble(
  metric = c(
    "pubmed_unique", "scopus_unique", "scopus_new_vs_pubmed",
    "embase_unique", "embase_new_vs_pubmed_scopus", "combined_unique"
  ),
  records = c(
    value("pubmed_unique"), value("scopus_unique"), value("scopus_not_in_pubmed"),
    nrow(embase_unique), sum(embase_unique$new_vs_pubmed_scopus),
    value("combined_unique") + sum(embase_unique$new_vs_pubmed_scopus)
  )
)
readr::write_csv(
  multidatabase_summary,
  file.path(export_dir, "multidatabase-comparison-summary.csv"), na = ""
)
print(summary)
