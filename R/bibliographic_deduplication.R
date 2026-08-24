normalize_bibliographic_doi <- function(x) {
  x <- trimws(tolower(ifelse(is.na(x), "", x)))
  x <- sub("^doi:[[:space:]]*", "", x)
  sub("^https?://(dx[.])?doi[.]org/", "", x)
}

normalize_bibliographic_title <- function(x) {
  x <- ifelse(is.na(x), "", x)
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT", sub = "")
  x <- tolower(gsub("[^[:alnum:]]+", " ", x))
  trimws(gsub("[[:space:]]+", " ", x))
}

match_scopus_to_pubmed <- function(scopus, pubmed) {
  required_scopus <- c("doi", "title")
  required_pubmed <- c("pmid", "doi", "title")
  if (!all(required_scopus %in% names(scopus))) {
    stop("Scopus records must contain doi and title.", call. = FALSE)
  }
  if (!all(required_pubmed %in% names(pubmed))) {
    stop("PubMed records must contain pmid, doi and title.", call. = FALSE)
  }

  scopus$doi_normalized <- normalize_bibliographic_doi(scopus$doi)
  scopus$title_normalized <- normalize_bibliographic_title(scopus$title)
  pubmed_doi <- normalize_bibliographic_doi(pubmed$doi)
  pubmed_title <- normalize_bibliographic_title(pubmed$title)

  doi_index <- match(scopus$doi_normalized, pubmed_doi)
  doi_index[scopus$doi_normalized == ""] <- NA_integer_
  title_index <- match(scopus$title_normalized, pubmed_title)
  title_index[scopus$title_normalized == ""] <- NA_integer_
  matched_index <- ifelse(!is.na(doi_index), doi_index, title_index)

  scopus$matched_pubmed <- !is.na(matched_index)
  scopus$match_basis <- ifelse(
    !is.na(doi_index), "DOI", ifelse(!is.na(title_index), "TITLE", "NONE")
  )
  scopus$matched_pubmed_pmid <- ifelse(
    is.na(matched_index), NA_character_, as.character(pubmed$pmid[matched_index])
  )
  scopus
}
