source("scripts/00_setup.R")

required <- c("dplyr", "httr2", "readr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

strategies <- load_scoping_search_strategies(project_root) |>
  dplyr::filter(database == "Embase")
paths <- scoping_search_paths(project_paths)
runs <- lapply(seq_len(nrow(strategies)), function(index) {
  strategy <- strategies[index, ]
  outcome <- test_embase_connection(strategy, project_paths)
  new_search_run_manifest(
    strategy, "https://api.elsevier.com/content/embase/article",
    1L, if (outcome$ok) 1L else 0L, if (outcome$ok) NA else 0L,
    0L, if (outcome$ok) "API_TEST_ONLY" else "FAILED",
    http_status = outcome$http_status,
    error_class = if (outcome$ok) NA_character_ else "EMBASE_ACCESS_DENIED",
    error_message_sanitized = outcome$message,
    notes = "Connection test only; not a bibliographic search execution"
  )
}) |>
  dplyr::bind_rows()
readr::write_csv(runs, file.path(paths$logs, "embase-api-tests.csv"), na = "")
append_search_run_manifest(runs, project_root)
print(runs |> dplyr::select(search_strategy_id, http_status, completion_status, error_class))
