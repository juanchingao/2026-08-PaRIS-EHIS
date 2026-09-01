source("scripts/00_setup.R")

if (!nzchar(Sys.getenv("WOS_API_KEY_STARTER_SERMAS", "")) &&
    file.exists(file.path(project_root, ".Renviron"))) {
  readRenviron(file.path(project_root, ".Renviron"))
}
register <- readr::read_csv(
  file.path(project_root, "research", "scoping-review", "strategies",
            "master-search-register.csv"),
  show_col_types = FALSE, col_types = readr::cols(.default = "c")
) |>
  dplyr::filter(search_id %in% c(
    "WP1A-WOS-01", "WP1A-WOS-02", "WP1B-WOS-01",
    "WP1B-FUTURE-WOS-01"
  ))
rows <- list()
index <- 0L
for (strategy_index in seq_len(nrow(register))) {
  strategy <- register[strategy_index, ]
  for (sort_field in c("RS+D", "PY+D")) {
    response <- wos_starter_request(
      strategy$query, page = 1L, limit = 10L, sort_field = sort_field
    )
    hits <- wos_starter_hits(response$body)
    for (rank in seq_along(hits)) {
      index <- index + 1L
      rows[[index]] <- tibble::tibble(
        search_id = strategy$search_id,
        sort = if (sort_field == "RS+D") "relevance" else "date_descending",
        rank = rank,
        wos_ut = wos_scalar(hits[[rank]]$uid),
        title = wos_scalar(hits[[rank]]$title),
        year = wos_named_value(hits[[rank]]$source, c("publishyear", "year")),
        human_relevance = "PENDING_HUMAN_REVIEW",
        notes = ""
      )
    }
  }
}
output <- file.path(
  project_paths$outputs, "tables", "scoping-review",
  "wos-validation-samples.csv"
)
dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
readr::write_csv(dplyr::bind_rows(rows), output, na = "")
message("Validation sample written outside Git: ", output)
