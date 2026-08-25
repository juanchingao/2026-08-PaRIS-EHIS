source("scripts/00_setup.R")

required <- c("dplyr", "readr", "stringr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

strategies <- load_scoping_search_strategies(project_root)
if (!setequal(unique(strategies$search_line), c("A", "B", "C"))) {
  stop("Search lines must be exactly A, B and C.", call. = FALSE)
}
expected <- tidyr::expand_grid(
  database = c(
    "PubMed/MEDLINE", "Scopus", "Embase", "APA PsycINFO",
    "Web of Science Core Collection"
  ),
  search_line = c("A", "B", "C")
)
observed <- strategies |> dplyr::select(database, search_line)
if (nrow(dplyr::anti_join(expected, observed, by = c("database", "search_line")))) {
  stop("At least one database-line strategy is missing.", call. = FALSE)
}
if (any(stringr::str_detect(
  strategies$query,
  stringr::regex("(line A|SR-[A-Z]+-A).*(line B|SR-[A-Z]+-B)", ignore_case = TRUE)
))) {
  stop("Search lines may not be joined to each other.", call. = FALSE)
}

seed_path <- file.path(project_root, "research", "scoping-review", "seed-references.csv")
seeds <- readr::read_csv(seed_path, show_col_types = FALSE)
required_seed <- c(
  "seed_id", "citation", "doi", "pmid", "scopus_eid", "embase_id",
  "methodological_domain", "expected_search_line"
)
if (!all(required_seed %in% names(seeds)) || anyDuplicated(seeds$seed_id)) {
  stop("Seed reference schema or identifiers are invalid.", call. = FALSE)
}

paths <- scoping_search_paths(project_paths)
summary <- strategies |>
  dplyr::count(database, platform, status, name = "strategies") |>
  dplyr::arrange(database, status)
print(summary)
message("Validated 15 independent database-line strategies and ", nrow(seeds), " seeds.")
message("Generated storage paths are configured outside version control.")
