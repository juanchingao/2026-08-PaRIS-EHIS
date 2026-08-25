source("scripts/00_setup.R")

required <- c("dplyr", "readr", "stringr", "tibble", "tidyr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

paths <- scoping_search_paths(project_paths)
records <- readr::read_csv(
  file.path(paths$processed, "original-records.csv"), show_col_types = FALSE,
  col_types = readr::cols(.default = "c")
)
links <- readr::read_csv(
  file.path(paths$processed, "work-sources.csv"), show_col_types = FALSE,
  col_types = readr::cols(.default = "c")
)
works <- readr::read_csv(
  file.path(paths$processed, "works.csv"), show_col_types = FALSE,
  col_types = readr::cols(.default = "c")
)

historical_dir <- file.path(project_root, "research", "narrative-review")
pubmed_historical <- readr::read_csv(
  file.path(historical_dir, "screening.csv"), show_col_types = FALSE,
  col_types = readr::cols(.default = "c")
)
pubmed_export <- readr::read_csv(
  file.path(historical_dir, "exports", "pubmed-results.csv"), show_col_types = FALSE,
  col_types = readr::cols(.default = "c")
)
supplementary_historical <- readr::read_csv(
  file.path(historical_dir, "supplementary-screening.csv"), show_col_types = FALSE,
  col_types = readr::cols(.default = "c")
)

historical <- dplyr::bind_rows(
  pubmed_historical |>
    dplyr::left_join(
      pubmed_export |> dplyr::select(pmid, doi, year), by = "pmid"
    ) |>
    dplyr::transmute(
      historical_record_id = record_id, pmid, doi, title, year,
      historical_decision = investigator_decision
    ),
  supplementary_historical |>
    dplyr::transmute(
      historical_record_id = record_id, pmid, doi, title,
      year = NA_character_, historical_decision = investigator_decision
    )
) |>
  dplyr::mutate(
    doi_key = normalize_bibliographic_doi(doi),
    pmid_key = normalise_bibliographic_pmid(pmid),
    title_key = normalize_bibliographic_title(title)
  ) |>
  dplyr::filter(historical_decision %in% c("INCLUDE", "BACKGROUND", "EXCLUDE"))

work_history <- works |>
  dplyr::mutate(
    doi_key = normalize_bibliographic_doi(doi),
    pmid_key = normalise_bibliographic_pmid(pmid),
    title_key = normalize_bibliographic_title(title)
  ) |>
  dplyr::rowwise() |>
  dplyr::mutate(
    historical_indices = list(which(
      nzchar(doi_key) & historical$doi_key == doi_key |
        nzchar(pmid_key) & historical$pmid_key == pmid_key |
        nzchar(title_key) & historical$title_key == title_key
    )),
    historical_decision = if (length(historical_indices)) paste(sort(unique(
      historical$historical_decision[historical_indices]
    )), collapse = ";") else NA_character_
  ) |>
  dplyr::ungroup() |>
  dplyr::select(work_id, historical_decision)

line_works <- links |>
  dplyr::distinct(work_id, source_database, search_line) |>
  dplyr::left_join(work_history, by = "work_id")

pilot_summary <- line_works |>
  dplyr::group_by(source_database, search_line) |>
  dplyr::summarise(
    unique_works = dplyr::n_distinct(work_id),
    historical_decisions_available = sum(!is.na(historical_decision)),
    historical_include = sum(grepl("INCLUDE", dplyr::coalesce(historical_decision, ""))),
    historical_background = sum(grepl("BACKGROUND", dplyr::coalesce(historical_decision, ""))),
    historical_exclude = sum(grepl("EXCLUDE", dplyr::coalesce(historical_decision, ""))),
    preliminary_relevant_fraction = dplyr::if_else(
      historical_decisions_available > 0,
      (historical_include + historical_background) / historical_decisions_available,
      NA_real_
    ),
    .groups = "drop"
  ) |>
  dplyr::left_join(
    records |>
      dplyr::group_by(source_database, search_line) |>
      dplyr::summarise(
        source_records = dplyr::n(),
        abstract_available = sum(nzchar(dplyr::coalesce(abstract, ""))),
        abstract_available_fraction = mean(nzchar(dplyr::coalesce(abstract, ""))),
        .groups = "drop"
      ),
    by = c("source_database", "search_line")
  ) |>
  dplyr::mutate(
    interpretation = paste(
      "Historical JALR decisions use the earlier narrative-review criteria;",
      "fractions are pilot indicators, not WP1 precision estimates."
    )
  )

line_overlap <- links |>
  dplyr::distinct(work_id, source_database, search_line) |>
  dplyr::group_by(work_id, source_database) |>
  dplyr::summarise(lines = paste(sort(unique(search_line)), collapse = ";"),
                   .groups = "drop") |>
  dplyr::count(source_database, lines, name = "unique_works")

database_contribution <- links |>
  dplyr::distinct(work_id, source_database) |>
  dplyr::group_by(work_id) |>
  dplyr::summarise(databases = paste(sort(unique(source_database)), collapse = ";"),
                   .groups = "drop") |>
  dplyr::count(databases, name = "unique_works")

set.seed(20260825)
pilot_sample <- records |>
  dplyr::left_join(links |> dplyr::select(record_id, work_id), by = "record_id") |>
  dplyr::group_by(source_database, search_line) |>
  dplyr::group_modify(~ dplyr::slice_sample(.x, n = min(25L, nrow(.x)))) |>
  dplyr::ungroup() |>
  dplyr::transmute(
    work_id, record_id, source_database, search_line, title, abstract,
    human_decision = NA_character_, exclusion_reason = NA_character_,
    reviewer = NA_character_, review_date = NA_character_, notes = NA_character_
  )

versioned_report_dir <- file.path(project_root, "research", "scoping-review", "reports")
readr::write_csv(pilot_summary, file.path(versioned_report_dir, "pilot-summary.csv"), na = "")
readr::write_csv(line_overlap, file.path(versioned_report_dir, "line-overlap.csv"), na = "")
readr::write_csv(
  database_contribution,
  file.path(versioned_report_dir, "database-contribution.csv"), na = ""
)
# The sample may contain licensed Scopus titles, so it remains in ignored outputs.
readr::write_csv(pilot_sample, file.path(paths$reports, "pilot-screening-sample.csv"), na = "")
print(pilot_summary)
message("Prepared ", nrow(pilot_sample), " records for human pilot screening; no decisions assigned.")
