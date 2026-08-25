source("scripts/00_setup.R")

required <- c("dplyr", "readr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

paths <- scoping_search_paths(project_paths)
manifest <- readr::read_csv(
  file.path(project_root, "research", "scoping-review", "manifests", "search-runs.csv"),
  show_col_types = FALSE, col_types = readr::cols(.default = "c")
)
latest <- manifest |>
  dplyr::arrange(executed_at) |>
  dplyr::group_by(search_strategy_id) |>
  dplyr::slice_tail(n = 1L) |>
  dplyr::ungroup()
works_path <- file.path(paths$processed, "works.csv")
records_path <- file.path(paths$processed, "original-records.csv")
links_path <- file.path(paths$processed, "work-sources.csv")
works <- if (file.exists(works_path)) readr::read_csv(works_path, show_col_types = FALSE) else tibble::tibble()
records <- if (file.exists(records_path)) readr::read_csv(records_path, show_col_types = FALSE) else tibble::tibble()
links <- if (file.exists(links_path)) readr::read_csv(links_path, show_col_types = FALSE) else tibble::tibble()

record_counts <- if (nrow(records)) records |>
  dplyr::count(search_strategy_id, name = "records_after_within_source_dedup") else
  tibble::tibble(search_strategy_id = character(), records_after_within_source_dedup = integer())
incremental <- if (nrow(links)) links |>
  dplyr::distinct(work_id, search_strategy_id) |>
  dplyr::group_by(work_id) |>
  dplyr::mutate(strategy_count = dplyr::n()) |>
  dplyr::ungroup() |>
  dplyr::filter(strategy_count == 1L) |>
  dplyr::count(search_strategy_id, name = "incremental_unique_works") else
  tibble::tibble(search_strategy_id = character(), incremental_unique_works = integer())

summary <- latest |>
  dplyr::transmute(
    database, search_line, search_strategy_id,
    execution_status = completion_status,
    total_reported = suppressWarnings(as.integer(total_reported)),
    total_downloaded = suppressWarnings(as.integer(total_downloaded)),
    complete = completion_status == "COMPLETE", notes
  ) |>
  dplyr::left_join(record_counts, by = "search_strategy_id") |>
  dplyr::left_join(incremental, by = "search_strategy_id")
versioned_report_dir <- file.path(project_root, "research", "scoping-review", "reports")
readr::write_csv(summary, file.path(paths$reports, "search-summary.csv"), na = "")
readr::write_csv(summary, file.path(versioned_report_dir, "search-summary.csv"), na = "")
flow <- tibble::tibble(
  stage = c("database_records_downloaded", "original_records", "unique_works_exact_rules",
            "approximate_pairs_awaiting_review"),
  records = c(
    sum(summary$total_downloaded, na.rm = TRUE), nrow(records), nrow(works),
    if (file.exists(file.path(paths$processed, "approximate-duplicate-candidates.csv")))
      nrow(readr::read_csv(file.path(paths$processed, "approximate-duplicate-candidates.csv"),
                          show_col_types = FALSE)) else NA_integer_
  ),
  status = c("IDENTIFICATION", "IDENTIFICATION", "DEDUPLICATION", "PENDING_REVIEW")
)
readr::write_csv(flow, file.path(paths$reports, "prisma-flow.csv"), na = "")
readr::write_csv(flow, file.path(versioned_report_dir, "prisma-flow.csv"), na = "")
print(summary)
print(flow)
