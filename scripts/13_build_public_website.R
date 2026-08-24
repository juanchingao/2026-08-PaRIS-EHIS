source("scripts/00_setup.R")
source("R/public_project_status.R")

required <- c("dplyr", "jsonlite", "readr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
website_dir <- file.path(project_root, "website")
data_dir <- file.path(website_dir, "data")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

pubmed <- readr::read_csv(
  file.path(review_dir, "screening.csv"), show_col_types = FALSE
)
supplementary <- readr::read_csv(
  file.path(review_dir, "supplementary-screening.csv"), show_col_types = FALSE
)
paris_dictionary <- readr::read_csv(
  file.path(project_paths$metadata, "paris_cycle1_puf_dictionary.csv"),
  show_col_types = FALSE
)
ehis_dictionary <- readr::read_csv(
  file.path(project_paths$metadata, "ehis_wave3_anonymisation_dictionary.csv"),
  show_col_types = FALSE
)

status <- build_public_project_status(
  pubmed, supplementary,
  paris_variables = nrow(paris_dictionary),
  ehis_variables = nrow(ehis_dictionary)
)
jsonlite::write_json(
  status,
  file.path(data_dir, "project-status.json"),
  auto_unbox = TRUE,
  pretty = TRUE
)

strategies <- readr::read_csv(
  file.path(review_dir, "search-strategies.csv"), show_col_types = FALSE
)
public_strategy_fields <- intersect(
  c("strategy_id", "database", "search_date", "query", "filters", "objective", "status"),
  names(strategies)
)
jsonlite::write_json(
  strategies[, public_strategy_fields, drop = FALSE],
  file.path(data_dir, "search-strategies.json"),
  dataframe = "rows", auto_unbox = TRUE, pretty = TRUE, na = "null"
)
generated_dir <- file.path(website_dir, "generated")
dir.create(generated_dir, recursive = TRUE, showWarnings = FALSE)
strategy_markdown <- unlist(lapply(seq_len(nrow(strategies)), function(i) {
  row <- strategies[i, ]
  c(
    paste0("### ", row$strategy_id, " - ", row$database),
    "",
    paste0("**Objetivo:** ", row$objective),
    "",
    paste0("**Estado:** `", row$status, "`"),
    "",
    "```text",
    row$query,
    "```",
    ""
  )
}))
strategy_markdown <- head(strategy_markdown, -1L)
writeLines(
  enc2utf8(strategy_markdown),
  file.path(generated_dir, "search-strategies.md"),
  useBytes = TRUE
)

# PubMed metadata are regenerated from the public NCBI source. Licensed
# Scopus/Embase exports remain outside the deployable directory.
pubmed_results <- readr::read_csv(
  file.path(review_dir, "exports", "pubmed-results.csv"), show_col_types = FALSE
)
public_references <- pubmed |>
  dplyr::left_join(
    pubmed_results |>
      dplyr::select(pmid, doi, journal, year, pubmed_url),
    by = "pmid"
  ) |>
  dplyr::transmute(
    record_id, source = "PubMed", pmid = as.character(pmid),
    doi = dplyr::coalesce(doi, ""), title,
    journal = dplyr::coalesce(journal, ""), year,
    source_url = pubmed_url
  )
jsonlite::write_json(
  public_references,
  file.path(data_dir, "references.json"),
  dataframe = "rows", auto_unbox = TRUE, pretty = TRUE, na = "null"
)
message("Public website data written to: ", data_dir)
