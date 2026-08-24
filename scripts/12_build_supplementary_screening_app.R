source("scripts/00_setup.R")

required <- c("dplyr", "jsonlite", "readr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")
screening <- readr::read_csv(
  file.path(review_dir, "supplementary-screening.csv"), show_col_types = FALSE
)
candidates <- readr::read_csv(
  file.path(export_dir, "supplementary-ranked-candidates.csv"), show_col_types = FALSE
)

records <- screening |>
  dplyr::left_join(
    candidates |>
      dplyr::select(
        record_id, abstract, authors, journal, year, source_url, source_database,
        source_id, citations
      ),
    by = c("record_id", "source_database", "source_id")
  ) |>
  dplyr::mutate(
    pmid = paste(source_database, source_id, sep = ":"),
    pubmed_url = source_url,
    proposed_reason = paste0(
      proposed_reason, "; source=", source_database,
      dplyr::if_else(source_database == "Scopus", "; citations=", ""),
      dplyr::if_else(source_database == "Scopus", as.character(citations), "")
    ),
    dplyr::across(dplyr::everything(), ~ dplyr::coalesce(as.character(.x), ""))
  )

template_path <- file.path(review_dir, "screening-review-template.html")
output_path <- file.path(review_dir, "supplementary-screening-review.html")
template <- paste(readLines(template_path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
template <- sub("__APP_TITLE__", "Cribado suplementario Scopus–Embase", template, fixed = TRUE)
template <- sub("__APP_TITLE__", "Cribado suplementario Scopus–Embase", template, fixed = TRUE)
template <- sub("__STORAGE_KEY__", "paris-ehis-supplementary-screening-v2", template, fixed = TRUE)
template <- sub("__HANDLE_KEY__", "supplementary-screening", template, fixed = TRUE)
template <- sub(
  "__SCREENING_FILENAME__", "supplementary-screening.csv", template, fixed = TRUE
)
payload <- jsonlite::toJSON(records, dataframe = "rows", auto_unbox = TRUE, na = "null")
html <- sub("__SCREENING_DATA__", payload, template, fixed = TRUE)

escape_html <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}
first <- records[1, ]
fallback <- paste0(
  '<div class="meta">1 de ', nrow(records), " · ID ", escape_html(first$pmid),
  " · ", escape_html(first$year), " · ", escape_html(first$journal), "</div>",
  "<h2>", escape_html(first$title), "</h2>",
  '<div class="meta">', escape_html(first$authors), "</div>",
  '<p><a href="', escape_html(first$pubmed_url),
  '" target="_blank">Abrir registro fuente ↗</a></p>',
  '<div class="abstract">', escape_html(first$abstract), "</div>",
  '<div class="proposal"><b>Prioridad: ', escape_html(first$proposed_decision),
  "</b><br>", escape_html(first$proposed_reason), "</div>"
)
html <- sub("__FIRST_RECORD__", fallback, html, fixed = TRUE)
writeLines(enc2utf8(html), output_path, useBytes = TRUE)
message("Supplementary screening app written to: ", output_path)
