source("scripts/00_setup.R")

required <- c("dplyr", "jsonlite", "readr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
screening <- readr::read_csv(file.path(review_dir, "screening.csv"), show_col_types = FALSE)
reviewed <- readr::read_csv(file.path(review_dir, "reviewed-screening.csv"), show_col_types = FALSE)

records <- screening |>
  dplyr::left_join(
    reviewed |> dplyr::select(record_id, abstract, authors, journal, year, pubmed_url),
    by = "record_id"
  ) |>
  dplyr::mutate(dplyr::across(dplyr::everything(), ~ dplyr::coalesce(as.character(.x), "")))

template_path <- file.path(review_dir, "screening-review-template.html")
output_path <- file.path(review_dir, "screening-review.html")
template <- paste(readLines(template_path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
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
  '<div class="meta">1 de ', nrow(records), " · PMID ", escape_html(first$pmid),
  " · ", escape_html(first$year), " · ", escape_html(first$journal), "</div>",
  "<h2>", escape_html(first$title), "</h2>",
  '<div class="meta">', escape_html(first$authors), "</div>",
  '<p><a href="', escape_html(first$pubmed_url), '" target="_blank">Abrir en PubMed ↗</a></p>',
  '<div class="abstract">', escape_html(first$abstract), "</div>",
  '<div class="proposal"><b>Propuesta: ', escape_html(first$proposed_decision),
  "</b><br>", escape_html(first$proposed_reason), "</div>",
  '<p><b>La ficha está cargada.</b> Si no aparecen los botones de decisión, abre este archivo con Edge, Chrome o Firefox.</p>'
)
html <- sub("__FIRST_RECORD__", fallback, html, fixed = TRUE)
writeLines(enc2utf8(html), output_path, useBytes = TRUE)
message("Screening review app written to: ", output_path)
