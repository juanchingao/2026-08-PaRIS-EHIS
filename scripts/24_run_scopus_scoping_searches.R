source("scripts/00_setup.R")

required <- c("digest", "dplyr", "readr", "scopusflow", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

strategies <- load_scoping_search_strategies(project_root) |>
  dplyr::filter(database == "Scopus")
paths <- scoping_search_paths(project_paths)
runs <- list()
subquery_manifests <- list()

for (index in seq_len(nrow(strategies))) {
  strategy <- strategies[index, ]
  message("Running ", strategy$search_strategy_id, "...")
  outcome <- tryCatch(
    run_scopus_strategy(strategy, project_paths, page_size = 25L),
    error = function(error) error
  )
  if (inherits(outcome, "error")) {
    runs[[index]] <- new_search_run_manifest(
      strategy, "https://api.elsevier.com/content/search/scopus",
      25L, NA, NA, 0L, "FAILED", http_status = NA,
      error_class = class(outcome)[[1]],
      error_message_sanitized = conditionMessage(outcome)
    )
    next
  }
  record_path <- file.path(
    paths$interim, paste0(tolower(strategy$search_strategy_id), "-records.csv")
  )
  subquery_path <- file.path(
    paths$logs, paste0(tolower(strategy$search_strategy_id), "-subqueries.csv")
  )
  readr::write_csv(outcome$records, record_path, na = "")
  readr::write_csv(outcome$subqueries, subquery_path, na = "")
  subquery_manifests[[index]] <- outcome$subqueries
  checksum <- digest::digest(
    paste(outcome$records$source_record_id, collapse = "|"),
    algo = "sha256", serialize = FALSE
  )
  runs[[index]] <- new_search_run_manifest(
    strategy, "https://api.elsevier.com/content/search/scopus",
    25L, outcome$page_count, outcome$total_reported,
    outcome$total_downloaded, if (outcome$complete) "COMPLETE" else "TRUNCATED",
    raw_manifest = relative_project_path(subquery_path), raw_checksum = checksum,
    notes = paste0(
      "scopusflow 0.4.0; exact logical union of atomic subqueries; paging=",
      outcome$paging, "; subquery_total_sum=", outcome$total_reported_sum,
      "; subquery_overlap=", outcome$subquery_overlap,
      "; Search API does not include authorised abstracts"
    )
  )
}

runs <- dplyr::bind_rows(runs)
readr::write_csv(runs, file.path(paths$logs, "scopus-search-runs.csv"), na = "")
versioned_subquery_path <- file.path(
  project_root, "research", "scoping-review", "manifests",
  "scopus-subqueries.csv"
)
readr::write_csv(
  dplyr::bind_rows(subquery_manifests), versioned_subquery_path, na = ""
)
append_search_run_manifest(runs, project_root)
print(runs |> dplyr::select(search_strategy_id, total_reported, total_downloaded, completion_status))
if (any(runs$completion_status != "COMPLETE")) {
  warning("At least one Scopus line did not complete.", call. = FALSE)
}
