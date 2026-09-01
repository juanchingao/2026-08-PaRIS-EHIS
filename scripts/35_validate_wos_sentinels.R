source("scripts/00_setup.R")

runs <- readr::read_csv(
  file.path(project_root, "research", "scoping-review", "manifests",
            "wos-runs.csv"),
  show_col_types = FALSE, col_types = readr::cols(.default = "c")
) |>
  dplyr::filter(complete == "TRUE", pilot == "FALSE")
records <- dplyr::bind_rows(lapply(runs$normalized_path, function(path) {
  readr::read_csv(
    path, show_col_types = FALSE, col_types = readr::cols(.default = "c")
  )
}))
sentinels <- readr::read_csv(
  file.path(project_root, "research", "scoping-review", "sentinel-articles.csv"),
  show_col_types = FALSE, col_types = readr::cols(.default = "c")
)
validation <- lapply(seq_len(nrow(sentinels)), function(index) {
  doi <- normalize_bibliographic_doi(sentinels$doi[[index]])
  matches <- records[
    normalize_bibliographic_doi(records$doi) == doi, , drop = FALSE
  ]
  tibble::tibble(
    sentinel_id = sentinels$sentinel_id[[index]],
    doi = sentinels$doi[[index]],
    wos_retrieved = nrow(matches) > 0L,
    retrieved_by = paste(unique(matches$search_strategy_id), collapse = ";"),
    validation_basis = "DOI match in completed faithful WoS runs",
    human_validation_status = "PENDING_HUMAN_VALIDATION"
  )
}) |>
  dplyr::bind_rows()
readr::write_csv(
  validation,
  file.path(project_root, "research", "scoping-review", "reports",
            "wos-sentinel-validation.csv"),
  na = ""
)
print(validation)
