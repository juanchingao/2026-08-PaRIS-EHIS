source("scripts/00_setup.R")

required <- c("digest", "dplyr", "httr2", "jsonlite", "readr", "stringr", "tibble", "xml2")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

load_bibliographic_credentials(project_root)
strategies <- load_scoping_search_strategies(project_root) |>
  dplyr::filter(database == "PubMed/MEDLINE")
paths <- scoping_search_paths(project_paths)
runs <- list()

for (index in seq_len(nrow(strategies))) {
  strategy <- strategies[index, ]
  message("Running ", strategy$search_strategy_id, "...")
  outcome <- tryCatch(
    run_pubmed_strategy(strategy, project_paths, page_size = 1000L, resume = TRUE),
    error = function(error) error
  )
  if (inherits(outcome, "error")) {
    runs[[index]] <- new_search_run_manifest(
      strategy, "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/",
      1000L, NA, NA, 0L, "FAILED", http_status = NA,
      error_class = class(outcome)[[1]],
      error_message_sanitized = conditionMessage(outcome)
    )
    next
  }
  record_path <- file.path(
    paths$interim, paste0(tolower(strategy$search_strategy_id), "-records.csv")
  )
  page_path <- file.path(
    paths$logs, paste0(tolower(strategy$search_strategy_id), "-pages.csv")
  )
  readr::write_csv(outcome$records, record_path, na = "")
  readr::write_csv(outcome$pages, page_path, na = "")
  checksum <- digest::digest(
    paste(outcome$pages$sha256, collapse = ""), algo = "sha256", serialize = FALSE
  )
  runs[[index]] <- new_search_run_manifest(
    strategy, "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/",
    1000L, outcome$page_count, outcome$total_reported,
    outcome$total_downloaded, if (outcome$complete) "COMPLETE" else "TRUNCATED",
    raw_manifest = relative_project_path(page_path), raw_checksum = checksum,
    notes = paste0(
      "ESearch history plus paginated EFetch XML; partitions=",
      outcome$partition_count, "; partition_total=", outcome$partition_total,
      "; cross_partition_duplicate_rows=", outcome$partition_overlap
    )
  )
}

runs <- dplyr::bind_rows(runs)
readr::write_csv(runs, file.path(paths$logs, "pubmed-search-runs.csv"), na = "")
append_search_run_manifest(runs, project_root)
print(runs |> dplyr::select(search_strategy_id, total_reported, total_downloaded, completion_status))
if (any(runs$completion_status != "COMPLETE")) {
  warning("At least one PubMed line did not complete.", call. = FALSE)
}
