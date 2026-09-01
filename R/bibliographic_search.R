bibliographic_schema <- function() {
  c(
    "record_id", "source_database", "source_record_id", "search_line",
    "search_strategy_id", "search_version", "search_date", "title",
    "abstract", "authors", "affiliations", "year", "publication_date",
    "journal", "doi", "pmid", "wos_ut", "scopus_eid", "embase_id",
    "keywords", "keywords_plus", "controlled_terms", "document_type",
    "language", "funding", "citation_count", "stream_tags", "raw_file",
    "raw_batch"
  )
}

valid_search_strategy_states <- function() {
  c(
    "DRAFT", "SYNTAX_CHECKED", "API_TESTED", "PILOTED",
    "SEED_VALIDATED", "PRESS_REVIEWED", "FINAL"
  )
}

load_scoping_search_strategies <- function(root = getwd()) {
  path <- file.path(
    root, "research", "scoping-review", "strategies",
    "search-strategies-v0.3.csv"
  )
  strategies <- readr::read_csv(path, show_col_types = FALSE)
  register_path <- file.path(
    root, "research", "scoping-review", "strategies", "strategy-register.csv"
  )
  if (file.exists(register_path)) {
    current_states <- readr::read_csv(register_path, show_col_types = FALSE) |>
      dplyr::select(search_strategy_id, current_status = status)
    strategies <- strategies |>
      dplyr::left_join(current_states, by = "search_strategy_id") |>
      dplyr::mutate(status = dplyr::coalesce(current_status, status)) |>
      dplyr::select(-current_status)
  }
  required <- c(
    "search_strategy_id", "search_version", "search_line", "database",
    "platform", "query", "status"
  )
  missing <- setdiff(required, names(strategies))
  if (length(missing)) {
    stop("Search strategies are missing fields: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  invalid_states <- setdiff(unique(strategies$status), valid_search_strategy_states())
  if (length(invalid_states)) {
    stop(
      "Invalid strategy status: ", paste(invalid_states, collapse = ", "),
      call. = FALSE
    )
  }
  duplicated_key <- duplicated(strategies$search_strategy_id)
  if (any(duplicated_key)) {
    stop("Duplicate search_strategy_id values.", call. = FALSE)
  }
  strategies
}

scoping_search_paths <- function(paths) {
  result <- list(
    raw = file.path(paths$raw, "scoping-review"),
    interim = file.path(paths$interim, "scoping-review"),
    processed = file.path(paths$derived, "scoping-review"),
    logs = file.path(paths$logs, "scoping-review"),
    reports = file.path(paths$outputs, "tables", "scoping-review")
  )
  invisible(lapply(result, dir.create, recursive = TRUE, showWarnings = FALSE))
  result
}

load_bibliographic_credentials <- function(root = getwd()) {
  candidates <- c(path.expand("~/.Renviron"), file.path(root, ".Renviron"))
  invisible(lapply(candidates[file.exists(candidates)], readRenviron))
}

sanitise_http_message <- function(message) {
  message <- gsub("(?i)(api[-_ ]?key|token|authorization)\\s*[:=]\\s*[^ ;,]+",
                  "\\1=[REDACTED]", as.character(message), perl = TRUE)
  message <- gsub("\r", " ", message, fixed = TRUE)
  message <- gsub("\n", " ", message, fixed = TRUE)
  substr(message, 1L, 500L)
}

relative_project_path <- function(path, root = getwd()) {
  root <- paste0(normalizePath(root, winslash = "/", mustWork = TRUE), "/")
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  sub(paste0("^", gsub("([][{}()+*^$|\\?.])", "\\\\\\1", root)), "", path)
}

file_sha256 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

empty_bibliographic_records <- function() {
  tibble::as_tibble(stats::setNames(
    rep(list(character()), length(bibliographic_schema())),
    bibliographic_schema()
  ))
}

conform_bibliographic_schema <- function(records) {
  for (field in setdiff(bibliographic_schema(), names(records))) {
    records[[field]] <- NA_character_
  }
  records <- records[, bibliographic_schema(), drop = FALSE]
  records[] <- lapply(records, as.character)
  tibble::as_tibble(records)
}

write_raw_once <- function(response, path) {
  if (file.exists(path)) return(invisible(FALSE))
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- paste0(path, ".part")
  writeBin(httr2::resp_body_raw(response), temporary)
  if (!file.rename(temporary, path)) {
    unlink(temporary)
    stop("Could not atomically create raw response: ", path, call. = FALSE)
  }
  invisible(TRUE)
}

pubmed_request <- function(endpoint, api_key = Sys.getenv("NCBI_API_KEY", ""),
                           email = Sys.getenv("NCBI_EMAIL", "")) {
  request <- httr2::request(paste0(
    "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/", endpoint, ".fcgi"
  )) |>
    httr2::req_user_agent("PaRISEHIS-scoping-review/0.3") |>
    httr2::req_timeout(seconds = 60) |>
    httr2::req_url_query(tool = "parisehis_scoping_review")
  if (nzchar(api_key)) request <- httr2::req_url_query(request, api_key = api_key)
  if (nzchar(email)) request <- httr2::req_url_query(request, email = email)
  request
}

pubmed_pause <- function() {
  if (nzchar(Sys.getenv("NCBI_API_KEY", ""))) Sys.sleep(0.12) else Sys.sleep(0.36)
}

xml_text_or_na <- function(node, xpath) {
  found <- xml2::xml_find_first(node, xpath)
  if (inherits(found, "xml_missing")) return(NA_character_)
  value <- stringr::str_squish(xml2::xml_text(found))
  if (nzchar(value)) value else NA_character_
}

xml_collapse <- function(node, xpath, separator = "; ") {
  found <- xml2::xml_find_all(node, xpath)
  if (!length(found)) return(NA_character_)
  values <- unique(stringr::str_squish(xml2::xml_text(found)))
  values <- values[nzchar(values)]
  if (length(values)) paste(values, collapse = separator) else NA_character_
}

parse_pubmed_xml <- function(path, strategy, batch_id) {
  document <- xml2::read_xml(path)
  articles <- xml2::xml_find_all(document, "//PubmedArticle | //PubmedBookArticle")
  if (!length(articles)) return(empty_bibliographic_records())

  vector_text <- function(xpath) {
    nodes <- xml2::xml_find_first(articles, xpath)
    values <- stringr::str_squish(xml2::xml_text(nodes))
    values[!nzchar(values)] <- NA_character_
    values
  }
  pmids <- vector_text(".//MedlineCitation/PMID | .//BookDocument/PMID")
  dois <- vector_text(
    ".//PubmedData/ArticleIdList/ArticleId[@IdType='doi'] | .//PubmedBookData/ArticleIdList/ArticleId[@IdType='doi']"
  )
  years <- vector_text(
    ".//Article/Journal/JournalIssue/PubDate/Year | .//BookDocument/Book/PubDate/Year"
  )
  medline_dates <- vector_text(".//Article/Journal/JournalIssue/PubDate/MedlineDate")
  missing_year <- is.na(years)
  years[missing_year] <- stringr::str_extract(
    medline_dates[missing_year], "[12][0-9]{3}"
  )
  titles <- vector_text(
    ".//Article/ArticleTitle | .//BookDocument/ArticleTitle | .//BookDocument/Book/BookTitle"
  )
  journals <- vector_text(".//Article/Journal/Title | .//BookDocument/Book/BookTitle")

  collapse_nodes_by_pmid <- function(nodes, values, separator = "; ") {
    output <- rep(NA_character_, length(pmids))
    if (!length(nodes)) return(output)
    node_pmids <- xml2::xml_text(xml2::xml_find_first(
      nodes,
      "ancestor::*[self::PubmedArticle or self::PubmedBookArticle]/*[self::MedlineCitation or self::BookDocument]/PMID"
    ))
    grouped <- split(values, node_pmids)
    collapsed <- vapply(grouped, function(items) {
      items <- unique(stringr::str_squish(items))
      items <- items[nzchar(items)]
      if (length(items)) paste(items, collapse = separator) else NA_character_
    }, character(1))
    output <- unname(collapsed[match(pmids, names(collapsed))])
    output
  }

  author_nodes <- xml2::xml_find_all(
    document,
    "//PubmedArticle//Article/AuthorList/Author | //PubmedBookArticle//BookDocument/AuthorList/Author"
  )
  collective <- stringr::str_squish(xml2::xml_text(
    xml2::xml_find_first(author_nodes, "./CollectiveName")
  ))
  last_name <- stringr::str_squish(xml2::xml_text(
    xml2::xml_find_first(author_nodes, "./LastName")
  ))
  fore_name <- stringr::str_squish(xml2::xml_text(
    xml2::xml_find_first(author_nodes, "./ForeName")
  ))
  author_values <- stringr::str_squish(paste(last_name, fore_name))
  author_values[nzchar(collective)] <- collective[nzchar(collective)]
  authors <- collapse_nodes_by_pmid(author_nodes, author_values)

  abstract_nodes <- xml2::xml_find_all(
    document, "//PubmedArticle//Abstract/AbstractText | //PubmedBookArticle//Abstract/AbstractText"
  )
  abstract_values <- stringr::str_squish(xml2::xml_text(abstract_nodes))
  labels <- xml2::xml_attr(abstract_nodes, "Label")
  labelled <- !is.na(labels) & nzchar(labels)
  abstract_values[labelled] <- paste0(labels[labelled], ": ", abstract_values[labelled])
  abstracts <- collapse_nodes_by_pmid(abstract_nodes, abstract_values, " ")

  keyword_nodes <- xml2::xml_find_all(
    document, "//PubmedArticle//KeywordList/Keyword | //PubmedBookArticle//KeywordList/Keyword"
  )
  keywords <- collapse_nodes_by_pmid(keyword_nodes, xml2::xml_text(keyword_nodes))
  mesh_nodes <- xml2::xml_find_all(
    document, "//PubmedArticle//MeshHeading/DescriptorName | //PubmedBookArticle//MeshHeading/DescriptorName"
  )
  mesh <- collapse_nodes_by_pmid(mesh_nodes, xml2::xml_text(mesh_nodes))
  type_nodes <- xml2::xml_find_all(
    document, "//PubmedArticle//PublicationTypeList/PublicationType | //PubmedBookArticle//PublicationType"
  )
  types <- collapse_nodes_by_pmid(type_nodes, xml2::xml_text(type_nodes))
  language_nodes <- xml2::xml_find_all(
    document, "//PubmedArticle//Article/Language | //PubmedBookArticle//BookDocument/Language"
  )
  languages <- collapse_nodes_by_pmid(language_nodes, xml2::xml_text(language_nodes))

  tibble::tibble(
    record_id = paste0("PUBMED-", pmids, "-", strategy$search_line),
    source_database = "PubMed/MEDLINE", source_record_id = pmids,
    search_line = strategy$search_line,
    search_strategy_id = strategy$search_strategy_id,
    search_version = strategy$search_version,
    search_date = as.character(Sys.Date()), title = titles,
    abstract = abstracts, authors = authors, year = years, journal = journals,
    doi = dois, pmid = pmids, scopus_eid = NA_character_, embase_id = NA_character_,
    keywords = keywords, controlled_terms = mesh, document_type = types,
    language = languages, raw_file = relative_project_path(path), raw_batch = batch_id
  ) |>
    conform_bibliographic_schema()
}

run_pubmed_strategy <- function(strategy, paths, page_size = 200L,
                                resume = TRUE) {
  stopifnot(nrow(strategy) == 1L, strategy$database == "PubMed/MEDLINE")
  output_paths <- scoping_search_paths(paths)
  query_hash <- substr(digest::digest(
    strategy$query, algo = "sha256", serialize = FALSE
  ), 1L, 12L)
  raw_dir <- file.path(
    output_paths$raw, "pubmed", strategy$search_strategy_id,
    paste0("v", strategy$search_version, "-", query_hash)
  )
  dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

  search_history <- function(term) {
    response <- pubmed_request("esearch") |>
      httr2::req_url_query(
        db = "pubmed", term = term, retmode = "json", retmax = 0,
        usehistory = "y"
      ) |>
      httr2::req_retry(max_tries = 4) |>
      httr2::req_perform()
    httr2::resp_check_status(response)
    body <- httr2::resp_body_json(response, simplifyVector = FALSE)$esearchresult
    pubmed_pause()
    list(
      term = term, total = as.integer(body$count), webenv = body$webenv,
      query_key = body$querykey
    )
  }

  original <- search_history(strategy$query)
  total <- original$total
  partitions <- list()
  partition_index <- 0L
  add_partition <- function(start_year, end_year) {
    term <- paste0(
      "(", strategy$query, ") AND (\"", start_year,
      "/01/01\"[Date - Publication] : \"", end_year,
      "/12/31\"[Date - Publication])"
    )
    history <- search_history(term)
    if (history$total > 9999L && start_year < end_year) {
      midpoint <- floor((start_year + end_year) / 2)
      add_partition(start_year, midpoint)
      add_partition(midpoint + 1L, end_year)
    } else {
      partition_index <<- partition_index + 1L
      history$partition_id <- paste0(start_year, "-", end_year)
      partitions[[partition_index]] <<- history
    }
  }
  if (total > 9999L) {
    add_partition(1000L, as.integer(format(Sys.Date(), "%Y")) + 1L)
  } else {
    original$partition_id <- "all"
    partitions <- list(original)
  }
  partition_total <- sum(vapply(partitions, `[[`, integer(1), "total"))

  page_rows <- list()
  page_manifest <- list()
  page_index <- 0L
  for (partition in partitions) {
    if (is.null(partition$webenv) || is.null(partition$query_key)) {
      stop("PubMed did not return a history context.", call. = FALSE)
    }
    starts <- if (partition$total) {
      seq.int(0L, partition$total - 1L, by = page_size)
    } else integer()
    for (start in starts) {
      page_index <- page_index + 1L
      batch_id <- sprintf(
        "%s-start-%09d-count-%05d", partition$partition_id, start, page_size
      )
      legacy_path <- file.path(
        raw_dir,
        paste0("batch-", sprintf("start-%09d-count-%05d", start, page_size), ".xml")
      )
      raw_path <- file.path(raw_dir, paste0("batch-", batch_id, ".xml"))
      if (partition$partition_id == "all" && file.exists(legacy_path)) {
        raw_path <- legacy_path
      }
      if (!file.exists(raw_path) || !isTRUE(resume)) {
        response <- pubmed_request("efetch") |>
          httr2::req_url_query(
            db = "pubmed", query_key = partition$query_key,
            WebEnv = partition$webenv, retstart = start, retmax = page_size,
            rettype = "abstract", retmode = "xml"
          ) |>
          httr2::req_retry(max_tries = 4) |>
          httr2::req_perform()
        httr2::resp_check_status(response)
        write_raw_once(response, raw_path)
        pubmed_pause()
      }
      page_rows[[page_index]] <- parse_pubmed_xml(raw_path, strategy, batch_id)
      page_manifest[[page_index]] <- tibble::tibble(
        partition_id = partition$partition_id,
        partition_total = partition$total,
        raw_batch = batch_id, retstart = start, requested = page_size,
        retrieved = nrow(page_rows[[page_index]]),
        raw_file = relative_project_path(raw_path), sha256 = file_sha256(raw_path)
      )
    }
  }
  records_with_partition_overlap <- conform_bibliographic_schema(
    dplyr::bind_rows(page_rows)
  )
  records <- records_with_partition_overlap |>
    dplyr::group_by(source_record_id) |>
    dplyr::mutate(
      raw_file = paste(unique(raw_file), collapse = ";"),
      raw_batch = paste(unique(raw_batch), collapse = ";")
    ) |>
    dplyr::slice_head(n = 1L) |>
    dplyr::ungroup()
  manifest <- dplyr::bind_rows(page_manifest)
  partition_overlap <- nrow(records_with_partition_overlap) - nrow(records)
  complete <- nrow(records) == total && !anyDuplicated(records$source_record_id)
  list(
    records = records, pages = manifest, total_reported = total,
    total_downloaded = nrow(records), page_count = nrow(manifest),
    partition_count = length(partitions), partition_total = partition_total,
    partition_overlap = partition_overlap, complete = complete,
    history_used = TRUE
  )
}

normalise_scopus_records <- function(records, strategy, raw_file) {
  if (!nrow(records)) return(empty_bibliographic_records())
  names(records) <- sub("^eid$", "scopus_id", names(records))
  source_id <- dplyr::coalesce(
    as.character(records[[if ("scopus_id" %in% names(records)) "scopus_id" else "entry_number"]]),
    as.character(records$entry_number)
  )
  tibble::tibble(
    record_id = paste0("SCOPUS-", source_id, "-", strategy$search_line),
    source_database = "Scopus",
    source_record_id = source_id,
    search_line = strategy$search_line,
    search_strategy_id = strategy$search_strategy_id,
    search_version = strategy$search_version,
    search_date = as.character(Sys.Date()),
    title = as.character(records$title),
    abstract = NA_character_,
    authors = as.character(records$authors),
    year = as.character(records$year),
    journal = as.character(records$publication),
    doi = as.character(records$doi),
    pmid = NA_character_,
    scopus_eid = source_id,
    embase_id = NA_character_,
    keywords = NA_character_,
    controlled_terms = NA_character_,
    document_type = NA_character_,
    language = NA_character_,
    raw_file = raw_file,
    raw_batch = as.character(records$query)
  ) |>
    conform_bibliographic_schema()
}

scopus_search_blocks <- function(search_line) {
  method_terms <- switch(
    search_line,
    A = c(
      "\"data harmonization\"", "\"data harmonisation\"",
      "\"retrospective harmonization\"", "\"retrospective harmonisation\"",
      "\"ex post harmonization\"", "\"ex-post harmonization\"",
      "\"ex post harmonisation\"", "\"ex-post harmonisation\"",
      "\"post hoc harmonization\"", "\"post hoc harmonisation\"",
      "\"pooled data harmonization\"", "\"pooled data harmonisation\"",
      "\"individual-level data harmonization\"",
      "\"individual-level data harmonisation\"",
      "\"variable harmonization\"", "\"variable harmonisation\"",
      "\"survey harmonization\"", "\"survey harmonisation\"",
      "\"questionnaire harmonization\"", "\"questionnaire harmonisation\"",
      "\"semantic harmonization\"", "\"semantic harmonisation\""
    ),
    B = c(
      "\"measurement equivalence\"", "\"measurement invariance\"",
      "\"construct equivalence\"", "\"conceptual equivalence\"",
      "\"semantic equivalence\"", "\"functional equivalence\"",
      "\"item equivalence\"", "\"question comparability\"",
      "\"questionnaire comparability\"", "\"cross-survey comparability\"",
      "\"cross-cultural comparability\"", "\"common metric\"",
      "\"scale linking\"", "\"score linking\"", "\"test equating\"",
      "crosswalk*", "\"item mapping\"", "\"variable mapping\"",
      "\"construct mapping\"", "\"anchor item\"", "\"anchor items\"",
      "\"bridging item\"", "\"bridging items\"", "\"bridging study\"",
      "\"differential item functioning\""
    ),
    C = c(
      "\"harmonization framework\"", "\"harmonisation framework\"",
      "\"harmonization protocol\"", "\"harmonisation protocol\"",
      "\"harmonization workflow\"", "\"harmonisation workflow\"",
      "\"harmonization algorithm\"", "\"harmonisation algorithm\"",
      "\"harmonization pipeline\"", "\"harmonisation pipeline\"",
      "\"harmonization platform\"", "\"harmonisation platform\"",
      "\"common data model\"", "\"metadata mapping\"",
      "\"ontology mapping\"", "\"schema mapping\"",
      "\"data integration framework\""
    ),
    stop("Unknown Scopus search line.", call. = FALSE)
  )
  context_terms <- switch(
    search_line,
    A = c(
      "survey*", "questionnaire*", "cohort*", "epidemiolog*",
      "\"population health\"", "\"health survey\"", "\"health surveys\"",
      "\"patient-reported measure\"", "\"patient-reported measures\"",
      "\"patient reported measure\"", "\"patient reported measures\"",
      "\"cross-national\"", "\"cross-country\"", "multicountry", "\"multi-country\""
    ),
    B = c(
      "survey*", "questionnaire*", "instrument*", "scale*", "cohort*",
      "\"population health\"", "\"health status\"",
      "\"patient-reported outcome\"", "\"patient-reported outcomes\"",
      "\"patient-reported experience measure\"",
      "\"patient-reported experience measures\""
    ),
    C = c(
      "survey*", "questionnaire*", "cohort*", "epidemiolog*",
      "\"population health\"", "\"patient-reported measure\"",
      "\"patient-reported measures\"", "\"patient reported measure\"",
      "\"patient reported measures\""
    )
  )
  list(method = method_terms, context = context_terms)
}

build_scopus_subqueries <- function(search_line, chunk_size = 4L) {
  blocks <- scopus_search_blocks(search_line)
  groups <- split(blocks$method, ceiling(seq_along(blocks$method) / chunk_size))
  tibble::tibble(
    subquery_id = sprintf("%s-SQ%02d", search_line, seq_along(groups)),
    query = vapply(groups, function(terms) paste0(
      "TITLE-ABS-KEY((", paste(terms, collapse = " OR "), ") AND (",
      paste(blocks$context, collapse = " OR "), "))"
    ), character(1))
  )
}

run_scopus_strategy <- function(strategy, paths, page_size = 200L,
                                hard_cap = 5000L,
                                partition_years = 1900:(as.integer(format(Sys.Date(), "%Y")) + 2L)) {
  stopifnot(nrow(strategy) == 1L, strategy$database == "Scopus")
  if (!requireNamespace("scopusflow", quietly = TRUE)) {
    stop("Package scopusflow is required.", call. = FALSE)
  }
  load_bibliographic_credentials(paths$root)
  api_key <- Sys.getenv("SCOPUS_API_KEY", "")
  inst_token <- Sys.getenv("SCOPUS_INST_TOKEN", "")
  if (!nzchar(api_key)) stop("SCOPUS_API_KEY is not configured.", call. = FALSE)
  output_paths <- scoping_search_paths(paths)
  raw_dir <- file.path(output_paths$raw, "scopus", strategy$search_strategy_id)
  dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

  subqueries <- build_scopus_subqueries(strategy$search_line)
  outputs <- vector("list", nrow(subqueries))
  audit <- vector("list", nrow(subqueries))
  for (index in seq_len(nrow(subqueries))) {
    subquery <- subqueries[index, ]
    total <- as.integer(scopusflow::scopus_count(
      subquery$query, api_key = api_key,
      inst_token = if (nzchar(inst_token)) inst_token else NULL
    ))
    subquery_dir <- file.path(raw_dir, tolower(subquery$subquery_id))
    dir.create(subquery_dir, recursive = TRUE, showWarnings = FALSE)
    if (total <= hard_cap) {
      fetched <- scopusflow::scopus_fetch(
        subquery$query, max_results = Inf, view = "STANDARD",
        page_size = page_size, cursor = FALSE, api_key = api_key,
        inst_token = if (nzchar(inst_token)) inst_token else NULL,
        verbose = TRUE
      )
      paging <- "offset"
    } else {
      plan <- scopusflow::scopus_plan(
        subquery$query, years = partition_years, view = "STANDARD",
        page_size = page_size, partition = "year"
      )
      fetched <- scopusflow::scopus_fetch_plan(
        plan, max_results = Inf, cache_dir = subquery_dir, resume = TRUE,
        api_key = api_key,
        inst_token = if (nzchar(inst_token)) inst_token else NULL,
        verbose = TRUE
      )
      paging <- "year_partition"
    }
    raw_name <- if (paging == "year_partition") {
      paste0("records-through-", max(partition_years), ".rds")
    } else {
      "records-offset.rds"
    }
    raw_path <- file.path(subquery_dir, raw_name)
    if (!file.exists(raw_path)) saveRDS(fetched, raw_path, version = 3)
    records <- as.data.frame(fetched)
    normalised <- normalise_scopus_records(
      records, strategy, relative_project_path(raw_path)
    )
    normalised$raw_batch <- subquery$subquery_id
    outputs[[index]] <- normalised
    audit[[index]] <- tibble::tibble(
      subquery_id = subquery$subquery_id, parent_strategy_id = strategy$search_strategy_id,
      query = subquery$query, paging = paging, total_reported = total,
      total_downloaded = nrow(normalised),
      unique_source_records = dplyr::n_distinct(normalised$source_record_id),
      duplicate_source_rows = nrow(normalised) - dplyr::n_distinct(normalised$source_record_id),
      complete = total == nrow(normalised),
      raw_file = relative_project_path(raw_path), sha256 = file_sha256(raw_path)
    )
  }
  all_records <- dplyr::bind_rows(outputs)
  normalised <- all_records |>
    dplyr::group_by(source_record_id) |>
    dplyr::mutate(
      raw_file = paste(unique(raw_file), collapse = ";"),
      raw_batch = paste(unique(raw_batch), collapse = ";")
    ) |>
    dplyr::slice_head(n = 1L) |>
    dplyr::ungroup()
  audit <- dplyr::bind_rows(audit)
  unique_ids <- unique(normalised$source_record_id)
  complete <- all(audit$complete)
  list(
    records = normalised,
    subqueries = audit,
    total_reported = length(unique_ids),
    total_downloaded = length(unique_ids),
    total_reported_sum = sum(audit$total_reported),
    subquery_overlap = nrow(all_records) - length(unique_ids),
    page_count = NA_integer_,
    complete = complete,
    paging = paste(unique(audit$paging), collapse = ";")
  )
}

test_embase_connection <- function(strategy, paths) {
  load_bibliographic_credentials(paths$root)
  api_key <- Sys.getenv("EMBASE_API_KEY", "")
  inst_token <- Sys.getenv("EMBASE_INST_TOKEN", "")
  if (!nzchar(api_key)) stop("EMBASE_API_KEY is not configured.", call. = FALSE)
  request <- httr2::request("https://api.elsevier.com/content/embase/article") |>
    httr2::req_headers(`X-ELS-APIKey` = api_key, Accept = "application/json") |>
    httr2::req_url_query(query = strategy$query, start = 1L, count = 1L) |>
    httr2::req_user_agent("PaRISEHIS-scoping-review/0.2")
  if (nzchar(inst_token)) {
    request <- httr2::req_headers(request, `X-ELS-Insttoken` = inst_token)
  }
  response <- tryCatch(
    httr2::req_perform(request),
    httr2_http = function(error) error$resp,
    httr2_failure = function(error) error
  )
  if (inherits(response, "httr2_response")) {
    status <- httr2::resp_status(response)
    message <- if (status >= 400L) {
      sanitise_http_message(httr2::resp_body_string(response))
    } else {
      "Connection successful"
    }
    return(list(ok = status < 400L, http_status = status, message = message))
  }
  list(
    ok = FALSE, http_status = NA_integer_,
    message = sanitise_http_message(conditionMessage(response))
  )
}

git_run_state <- function(root = getwd()) {
  commit <- tryCatch(
    system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE)[[1]],
    error = function(...) NA_character_
  )
  status <- tryCatch(
    system2("git", c("status", "--short"), stdout = TRUE, stderr = FALSE),
    error = function(...) character()
  )
  list(commit = commit, dirty = length(status) > 0L)
}

new_search_run_manifest <- function(
    strategy, endpoint, page_size, pages, total_reported, total_downloaded,
    completion_status, raw_manifest = NA_character_, raw_checksum = NA_character_,
    http_status = 200L, error_class = NA_character_,
    error_message_sanitized = NA_character_, notes = NA_character_) {
  git <- git_run_state()
  executed_at <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  tibble::tibble(
    run_id = paste(strategy$search_strategy_id, format(
      Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC"
    ), sep = "-"),
    search_strategy_id = strategy$search_strategy_id,
    search_version = strategy$search_version,
    search_line = strategy$search_line,
    database = strategy$database,
    platform = strategy$platform,
    executed_at = executed_at,
    endpoint = endpoint,
    filters = strategy$filters,
    page_size = as.character(page_size),
    pages = as.character(pages),
    total_reported = as.character(total_reported),
    total_downloaded = as.character(total_downloaded),
    completion_status = completion_status,
    http_status = as.character(http_status),
    error_class = error_class,
    error_message_sanitized = sanitise_http_message(error_message_sanitized),
    raw_manifest = raw_manifest,
    raw_checksum = raw_checksum,
    software_version = paste0("R ", getRversion()),
    git_commit = git$commit,
    dirty_worktree = git$dirty,
    notes = notes
  )
}

append_search_run_manifest <- function(rows, root = getwd()) {
  path <- file.path(
    root, "research", "scoping-review", "manifests", "search-runs.csv"
  )
  previous <- if (file.exists(path)) {
    readr::read_csv(path, show_col_types = FALSE, col_types = readr::cols(.default = "c"))
  } else {
    tibble::tibble()
  }
  rows <- dplyr::mutate(rows, dplyr::across(dplyr::everything(), as.character))
  combined <- dplyr::bind_rows(previous, rows) |>
    dplyr::distinct(run_id, .keep_all = TRUE)
  readr::write_csv(combined, path, na = "")
  invisible(combined)
}
