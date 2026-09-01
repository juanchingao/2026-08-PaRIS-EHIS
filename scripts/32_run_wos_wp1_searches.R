source("scripts/00_setup.R")

if (!nzchar(Sys.getenv("WOS_API_KEY_STARTER_SERMAS", "")) &&
    file.exists(file.path(project_root, ".Renviron"))) {
  readRenviron(file.path(project_root, ".Renviron"))
}

register_path <- file.path(
  project_root, "research", "scoping-review", "strategies",
  "master-search-register.csv"
)
run_register_path <- file.path(
  project_root, "research", "scoping-review", "manifests", "wos-runs.csv"
)
strategies <- readr::read_csv(
  register_path, show_col_types = FALSE, col_types = readr::cols(.default = "c")
)
arguments <- commandArgs(trailingOnly = TRUE)
mode <- if ("--execute-ready" %in% arguments) "execute" else "pilot"

if (mode == "execute") {
  selected <- dplyr::filter(
    strategies,
    search_id %in% c("WP1A-WOS-01", "WP1A-WOS-02"), status == "READY"
  )
} else {
  selected <- dplyr::filter(
    strategies,
    search_id %in% c(
      "WP1A-WOS-01", "WP1A-WOS-02", "WP1A-WOS-01-TS",
      "WP1A-WOS-02-TS", "WP1A-WOS-V2-PILOT", "WP1B-WOS-01",
      "WP1B-FUTURE-WOS-01"
    )
  )
}

if (!nrow(selected)) stop("No WoS strategies selected.", call. = FALSE)

rows <- list()
for (index in seq_len(nrow(selected))) {
  item <- selected[index, ]
  strategy <- list(
    search_strategy_id = item$search_id,
    search_line = item$work_package,
    query_version = item$query_version,
    query = item$query,
    stream_tags = item$stream_tags
  )
  result <- run_wos_starter_search(
    strategy, project_paths, pilot = mode == "pilot", pilot_pages = 1L,
    resume = FALSE
  )
  manifest <- result$manifest
  rows[[index]] <- tibble::tibble(
    run_id = manifest$run_id,
    search_id = manifest$search_id,
    query_version = manifest$query_version,
    work_package = item$work_package,
    stream_tags = item$stream_tags,
    api_type = manifest$api_type,
    endpoint = manifest$endpoint,
    executed_at_utc = manifest$timestamp_utc,
    total_reported = as.character(manifest$total_reported),
    total_retrieved = as.character(manifest$total_retrieved),
    pages_retrieved = as.character(manifest$pages_retrieved),
    complete = as.character(manifest$complete),
    pilot = as.character(manifest$pilot),
    manifest_path = relative_project_path(result$manifest_path),
    normalized_path = manifest$normalized_file,
    normalized_sha256 = manifest$normalized_sha256,
    notes = if (mode == "pilot") "Count plus first page; scientific review pending" else
      "Full authorized faithful TI/AB translation"
  )
  message(item$search_id, ": reported=", manifest$total_reported,
          "; retrieved=", manifest$total_retrieved,
          "; complete=", manifest$complete)
}

new_rows <- dplyr::bind_rows(rows)
old_rows <- if (file.exists(run_register_path)) {
  readr::read_csv(
    run_register_path, show_col_types = FALSE,
    col_types = readr::cols(.default = "c")
  )
} else tibble::tibble()
readr::write_csv(
  dplyr::bind_rows(old_rows, new_rows) |>
    dplyr::distinct(run_id, .keep_all = TRUE),
  run_register_path, na = ""
)
