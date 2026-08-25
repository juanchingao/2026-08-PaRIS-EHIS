source("scripts/00_setup.R")

required <- c("digest", "dplyr", "readr", "stringr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

paths <- scoping_search_paths(project_paths)
files <- list.files(paths$interim, pattern = "-records[.]csv$", full.names = TRUE)
if (!length(files)) stop("No normalized scoping-review records found.", call. = FALSE)
records <- dplyr::bind_rows(lapply(files, function(path) {
  readr::read_csv(path, show_col_types = FALSE, col_types = readr::cols(.default = "c"))
})) |>
  dplyr::distinct(record_id, .keep_all = TRUE)
corpus <- build_bibliographic_corpus(records)

readr::write_csv(corpus$records, file.path(paths$processed, "original-records.csv"), na = "")
readr::write_csv(corpus$works, file.path(paths$processed, "works.csv"), na = "")
readr::write_csv(corpus$work_sources, file.path(paths$processed, "work-sources.csv"), na = "")
readr::write_csv(
  corpus$deduplication_decisions,
  file.path(paths$processed, "deduplication-decisions.csv"), na = ""
)
readr::write_csv(
  corpus$approximate_candidates,
  file.path(paths$processed, "approximate-duplicate-candidates.csv"), na = ""
)
message("Original records: ", nrow(corpus$records))
message("Unique works after exact conservative rules: ", nrow(corpus$works))
message("Approximate pairs pending human review: ", nrow(corpus$approximate_candidates))
