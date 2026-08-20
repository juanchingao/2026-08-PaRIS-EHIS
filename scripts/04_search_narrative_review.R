source("scripts/00_setup.R")
options(timeout = max(60, getOption("timeout")))

required <- c("dplyr", "readr", "stringr", "tibble", "xml2")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")
dir.create(export_dir, recursive = TRUE, showWarnings = FALSE)

strategies <- readr::read_csv(
  file.path(review_dir, "search-strategies.csv"), show_col_types = FALSE
) |>
  dplyr::filter(database == "PubMed", status == "READY")

ncbi_get <- function(endpoint, parameters) {
  query <- paste(
    paste0(
      utils::URLencode(names(parameters), reserved = TRUE), "=",
      vapply(parameters, utils::URLencode, character(1), reserved = TRUE)
    ),
    collapse = "&"
  )
  xml2::read_xml(paste0(
    "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/", endpoint, "?", query
  ))
}

xml_text <- function(node, xpath) {
  result <- xml2::xml_find_first(node, xpath)
  if (inherits(result, "xml_missing")) NA_character_ else xml2::xml_text(result)
}

parse_article <- function(article, strategy_id) {
  authors <- xml2::xml_find_all(article, ".//AuthorList/Author")
  author_text <- vapply(authors, function(author) {
    collective <- xml_text(author, "./CollectiveName")
    if (!is.na(collective)) return(collective)
    paste(na.omit(c(xml_text(author, "./LastName"), xml_text(author, "./Initials"))), collapse = " ")
  }, character(1))
  ids <- xml2::xml_find_all(article, ".//ArticleId")
  id_types <- xml2::xml_attr(ids, "IdType")
  id_values <- xml2::xml_text(ids)
  get_id <- function(type) {
    value <- id_values[id_types == type]
    if (length(value)) value[[1]] else NA_character_
  }
  year <- xml_text(article, ".//JournalIssue/PubDate/Year")
  if (is.na(year)) {
    year <- stringr::str_extract(
      xml_text(article, ".//JournalIssue/PubDate/MedlineDate"), "[12][0-9]{3}"
    )
  }
  tibble::tibble(
    strategy_id = strategy_id,
    pmid = xml_text(article, ".//PMID"),
    doi = get_id("doi"),
    title = xml_text(article, ".//ArticleTitle"),
    abstract = paste(
      xml2::xml_text(xml2::xml_find_all(article, ".//Abstract/AbstractText")),
      collapse = " "
    ),
    authors = paste(author_text[nzchar(author_text)], collapse = "; "),
    journal = xml_text(article, ".//Journal/Title"),
    year = suppressWarnings(as.integer(year)),
    publication_types = paste(
      xml2::xml_text(xml2::xml_find_all(article, ".//PublicationType")),
      collapse = "; "
    ),
    pubmed_url = paste0(
      "https://pubmed.ncbi.nlm.nih.gov/", xml_text(article, ".//PMID"), "/"
    ),
    retrieved_date = as.character(Sys.Date())
  )
}

results <- list()
log_rows <- list()

for (i in seq_len(nrow(strategies))) {
  strategy <- strategies[i, ]
  search_xml <- ncbi_get("esearch.fcgi", list(
    db = "pubmed", term = strategy$query, retmode = "xml",
    retmax = as.character(strategy$max_records), sort = strategy$sort
  ))
  count <- as.integer(xml2::xml_text(xml2::xml_find_first(search_xml, ".//Count")))
  ids <- xml2::xml_text(xml2::xml_find_all(search_xml, ".//IdList/Id"))
  if (length(ids)) {
    batches <- split(ids, ceiling(seq_along(ids) / 50))
    batch_results <- vector("list", length(batches))
    for (j in seq_along(batches)) {
      Sys.sleep(0.4)
      fetch_xml <- ncbi_get("efetch.fcgi", list(
        db = "pubmed", id = paste(batches[[j]], collapse = ","), retmode = "xml"
      ))
      articles <- xml2::xml_find_all(fetch_xml, ".//PubmedArticle")
      batch_results[[j]] <- dplyr::bind_rows(
        lapply(articles, parse_article, strategy_id = strategy$strategy_id)
      )
    }
    results[[strategy$strategy_id]] <- dplyr::bind_rows(batch_results)
  }
  log_rows[[strategy$strategy_id]] <- tibble::tibble(
    search_id = strategy$strategy_id,
    search_date = as.character(Sys.Date()),
    database_or_site = "PubMed",
    objective = strategy$objective,
    exact_query = strategy$query,
    filters = "None; sorted by relevance",
    results_count = count,
    records_retrieved = length(ids),
    export_file = "research/narrative-review/exports/pubmed-results.csv",
    searcher = "R/NCBI E-utilities",
    notes = ifelse(
      count > strategy$max_records,
      "Retrieval capped at max_records", "Complete retrieval"
    )
  )
  Sys.sleep(0.4)
}

combined <- dplyr::bind_rows(results) |>
  dplyr::mutate(
    doi_normalized = stringr::str_to_lower(stringr::str_trim(doi)),
    dedup_key = dplyr::if_else(
      !is.na(pmid), paste0("pmid:", pmid), paste0("doi:", doi_normalized)
    )
  ) |>
  dplyr::group_by(dedup_key) |>
  dplyr::summarise(
    strategy_id = paste(sort(unique(strategy_id)), collapse = ";"),
    dplyr::across(-strategy_id, ~ dplyr::first(.x)),
    .groups = "drop"
  ) |>
  dplyr::select(-dedup_key)

readr::write_csv(combined, file.path(export_dir, "pubmed-results.csv"), na = "")
readr::write_csv(
  dplyr::bind_rows(log_rows), file.path(export_dir, "search-log.csv"), na = ""
)
message(
  "Retrieved ", nrow(combined), " unique PubMed records from ",
  nrow(strategies), " strategies."
)
