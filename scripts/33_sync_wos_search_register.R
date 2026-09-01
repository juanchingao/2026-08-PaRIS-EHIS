source("scripts/00_setup.R")

master_path <- file.path(
  project_root, "research", "scoping-review", "strategies",
  "master-search-register.csv"
)
runs_path <- file.path(
  project_root, "research", "scoping-review", "manifests", "wos-runs.csv"
)
master <- readr::read_csv(
  master_path, show_col_types = FALSE, col_types = readr::cols(.default = "c")
)
runs <- readr::read_csv(
  runs_path, show_col_types = FALSE, col_types = readr::cols(.default = "c")
)
latest_complete <- runs |>
  dplyr::filter(complete == "TRUE", pilot == "FALSE") |>
  dplyr::arrange(executed_at_utc) |>
  dplyr::group_by(search_id) |>
  dplyr::slice_tail(n = 1L) |>
  dplyr::ungroup() |>
  dplyr::select(
    search_id, date_executed_new = executed_at_utc,
    records_retrieved_new = total_retrieved,
    raw_output_location_new = manifest_path,
    normalized_output_location_new = normalized_path,
    checksum_new = normalized_sha256
  )
updated <- master |>
  dplyr::left_join(latest_complete, by = "search_id") |>
  dplyr::mutate(
    status = dplyr::if_else(!is.na(date_executed_new), "EXECUTED", status),
    date_validated = dplyr::if_else(
      !is.na(date_executed_new), substr(date_executed_new, 1L, 10L), date_validated
    ),
    date_executed = dplyr::coalesce(date_executed_new, date_executed),
    records_retrieved = dplyr::coalesce(
      records_retrieved_new, records_retrieved
    ),
    raw_output_location = dplyr::coalesce(
      raw_output_location_new, raw_output_location
    ),
    normalized_output_location = dplyr::coalesce(
      normalized_output_location_new, normalized_output_location
    ),
    checksum = dplyr::coalesce(checksum_new, checksum)
  ) |>
  dplyr::select(-dplyr::ends_with("_new"))
readr::write_csv(updated, master_path, na = "")
