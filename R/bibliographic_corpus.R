normalise_bibliographic_pmid <- function(x) {
  x <- trimws(ifelse(is.na(x), "", as.character(x)))
  ifelse(grepl("^[0-9]+$", x), x, "")
}

normalise_bibliographic_year <- function(x) {
  year <- stringr::str_extract(ifelse(is.na(x), "", as.character(x)), "[12][0-9]{3}")
  ifelse(is.na(year), "", year)
}

parse_tagged_records <- function(path, start_pattern, end_pattern, tag_pattern) {
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  starts <- which(grepl(start_pattern, lines))
  ends <- which(grepl(end_pattern, lines))
  if (!length(starts)) return(list())
  if (!length(ends)) ends <- c(starts[-1] - 1L, length(lines))
  lapply(seq_along(starts), function(index) {
    stop_at <- ends[which(ends >= starts[[index]])[1]]
    block <- lines[starts[[index]]:stop_at]
    fields <- list()
    current <- NULL
    for (line in block) {
      matched <- regmatches(line, regexec(tag_pattern, line))[[1]]
      if (length(matched)) {
        current <- matched[[2]]
        fields[[current]] <- c(fields[[current]], matched[[3]])
      } else if (!is.null(current) && grepl("^[[:space:]]+", line)) {
        last <- length(fields[[current]])
        fields[[current]][last] <- paste(fields[[current]][last], trimws(line))
      }
    }
    fields
  })
}

import_nbib_file <- function(path, strategy) {
  records <- parse_tagged_records(
    path, "^PMID-", "^$", "^([A-Z0-9]{2,4})[[:space:]]*-[[:space:]]?(.*)$"
  )
  value <- function(fields, tag, collapse = "; ") {
    values <- fields[[tag]]
    if (is.null(values)) NA_character_ else paste(values, collapse = collapse)
  }
  rows <- lapply(records, function(fields) {
    pmid <- value(fields, "PMID")
    tibble::tibble(
      record_id = paste0("PUBMED-", pmid, "-", strategy$search_line),
      source_database = "PubMed/MEDLINE", source_record_id = pmid,
      search_line = strategy$search_line,
      search_strategy_id = strategy$search_strategy_id,
      search_version = strategy$search_version,
      search_date = as.character(Sys.Date()),
      title = value(fields, "TI", " "), abstract = value(fields, "AB", " "),
      authors = value(fields, "AU"), year = value(fields, "DP"),
      journal = value(fields, "JT"), doi = value(fields, "LID"), pmid = pmid,
      keywords = value(fields, "OT"), controlled_terms = value(fields, "MH"),
      document_type = value(fields, "PT"), language = value(fields, "LA"),
      raw_file = relative_project_path(path), raw_batch = basename(path)
    )
  })
  conform_bibliographic_schema(dplyr::bind_rows(rows))
}

split_bibtex_entries <- function(text) {
  starts <- gregexpr("@[[:alpha:]]+[[:space:]]*\\{", text, perl = TRUE)[[1]]
  if (starts[[1]] < 0L) return(character())
  entries <- character(length(starts))
  for (index in seq_along(starts)) {
    chars <- strsplit(substr(text, starts[[index]], nchar(text)), "", fixed = TRUE)[[1]]
    depth <- 0L
    finish <- length(chars)
    for (position in seq_along(chars)) {
      if (chars[[position]] == "{") depth <- depth + 1L
      if (chars[[position]] == "}") depth <- depth - 1L
      if (depth == 0L && position > 1L) {
        finish <- position
        break
      }
    }
    entries[[index]] <- paste0(chars[seq_len(finish)], collapse = "")
  }
  entries
}

bibtex_field <- function(entry, field) {
  pattern <- paste0("(?is)(?:^|,)\\s*", field,
                    "\\s*=\\s*(?:\\{((?:[^{}]|\\{[^{}]*\\})*)\\}|\\\"([^\\\"]*)\\\")")
  matched <- regmatches(entry, regexec(pattern, entry, perl = TRUE))[[1]]
  if (length(matched) < 2L) return(NA_character_)
  value <- matched[2:3]
  value <- value[!is.na(value) & nzchar(value)]
  if (!length(value)) NA_character_ else stringr::str_squish(value[[1]])
}

import_bibtex_file <- function(path, strategy, source_database) {
  entries <- split_bibtex_entries(paste(readLines(
    path, encoding = "UTF-8", warn = FALSE
  ), collapse = "\n"))
  rows <- lapply(seq_along(entries), function(index) {
    entry <- entries[[index]]
    source_id <- bibtex_field(entry, "eid")
    if (is.na(source_id)) source_id <- bibtex_field(entry, "pmid")
    if (is.na(source_id)) source_id <- paste0("BIB-", index)
    tibble::tibble(
      record_id = paste0(toupper(gsub("[^A-Z]", "", source_database)), "-", source_id,
                         "-", strategy$search_line),
      source_database = source_database, source_record_id = source_id,
      search_line = strategy$search_line,
      search_strategy_id = strategy$search_strategy_id,
      search_version = strategy$search_version,
      search_date = as.character(Sys.Date()),
      title = bibtex_field(entry, "title"),
      abstract = bibtex_field(entry, "abstract"),
      authors = bibtex_field(entry, "author"), year = bibtex_field(entry, "year"),
      journal = bibtex_field(entry, "journal"), doi = bibtex_field(entry, "doi"),
      pmid = bibtex_field(entry, "pmid"),
      scopus_eid = if (source_database == "Scopus") source_id else NA_character_,
      embase_id = if (source_database == "Embase") source_id else NA_character_,
      keywords = bibtex_field(entry, "keywords"), controlled_terms = NA_character_,
      document_type = bibtex_field(entry, "type"),
      language = bibtex_field(entry, "language"),
      raw_file = relative_project_path(path), raw_batch = basename(path)
    )
  })
  conform_bibliographic_schema(dplyr::bind_rows(rows))
}

import_ris_bibliographic <- function(path, strategy, source_database) {
  records <- parse_ris_file(path, strategy$search_strategy_id)
  source_id <- if (source_database == "Embase") records$embase_id else
    records$source_record_id
  source_id[is.na(source_id) | !nzchar(source_id)] <- paste0(
    "RIS-", which(is.na(source_id) | !nzchar(source_id))
  )
  database_prefix <- toupper(gsub("[^A-Za-z0-9]", "", source_database))
  tibble::tibble(
    record_id = paste0(database_prefix, "-", source_id, "-", strategy$search_line),
    source_database = source_database, source_record_id = source_id,
    search_line = strategy$search_line,
    search_strategy_id = strategy$search_strategy_id,
    search_version = strategy$search_version,
    search_date = as.character(Sys.Date()), title = records$title,
    abstract = records$abstract, authors = records$authors, year = records$year,
    journal = records$journal, doi = records$doi, pmid = records$pmid,
    scopus_eid = if (source_database == "Scopus") source_id else NA_character_,
    embase_id = if (source_database == "Embase") source_id else NA_character_,
    keywords = records$keywords, controlled_terms = NA_character_,
    document_type = records$publication_type, language = NA_character_,
    raw_file = relative_project_path(path), raw_batch = basename(path)
  ) |>
    conform_bibliographic_schema()
}

import_manual_bibliographic_file <- function(path, strategy, source_database) {
  extension <- tolower(tools::file_ext(path))
  if (extension == "ris") return(import_ris_bibliographic(path, strategy, source_database))
  if (extension %in% c("bib", "bibtex")) {
    return(import_bibtex_file(path, strategy, source_database))
  }
  if (extension == "nbib") return(import_nbib_file(path, strategy))
  if (extension == "csv") {
    records <- readr::read_csv(path, show_col_types = FALSE)
    return(conform_bibliographic_schema(records))
  }
  stop("Unsupported bibliographic format: ", extension, call. = FALSE)
}

select_representative_value <- function(values) {
  values <- unique(as.character(values[!is.na(values) & nzchar(as.character(values))]))
  if (!length(values)) return(NA_character_)
  values[[which.max(nchar(values))]]
}

build_bibliographic_corpus <- function(records) {
  records <- conform_bibliographic_schema(records)
  if (anyDuplicated(records$record_id)) {
    stop("record_id must uniquely identify original search records.", call. = FALSE)
  }
  n <- nrow(records)
  parent <- seq_len(n)
  root <- function(index) {
    while (parent[[index]] != index) index <- parent[[index]]
    index
  }
  unite <- function(left, right) {
    left_root <- root(left)
    right_root <- root(right)
    if (left_root != right_root) parent[[right_root]] <<- left_root
  }
  decisions <- list()
  decision_index <- 0L

  apply_exact_rule <- function(keys, rule) {
    valid <- which(nzchar(keys))
    groups <- split(valid, keys[valid])
    for (indices in groups[lengths(groups) > 1L]) {
      anchor <- indices[[1]]
      for (candidate in indices[-1]) {
        if (root(anchor) != root(candidate)) {
          unite(anchor, candidate)
          decision_index <<- decision_index + 1L
          decisions[[decision_index]] <<- tibble::tibble(
            decision_id = sprintf("DEDUP-%06d", decision_index),
            record_id_1 = records$record_id[[anchor]],
            record_id_2 = records$record_id[[candidate]],
            rule = rule, decision = "MERGE_EXACT",
            reviewer = "DETERMINISTIC", decision_date = as.character(Sys.Date()),
            notes = "Exact controlled identifier or exact normalized title-year"
          )
        }
      }
    }
  }

  doi_key <- normalize_bibliographic_doi(records$doi)
  pmid_key <- normalise_bibliographic_pmid(records$pmid)
  wos_key <- trimws(ifelse(is.na(records$wos_ut), "", records$wos_ut))
  scopus_key <- trimws(ifelse(is.na(records$scopus_eid), "", records$scopus_eid))
  embase_key <- trimws(ifelse(is.na(records$embase_id), "", records$embase_id))
  title_key <- normalize_bibliographic_title(records$title)
  year_key <- normalise_bibliographic_year(records$year)
  apply_exact_rule(doi_key, "DOI")
  apply_exact_rule(pmid_key, "PMID")
  apply_exact_rule(wos_key, "WOS_UT")
  apply_exact_rule(scopus_key, "SCOPUS_EID")
  apply_exact_rule(embase_key, "EMBASE_ID")
  apply_exact_rule(ifelse(nzchar(title_key) & nzchar(year_key),
                          paste(title_key, year_key, sep = "|"), ""), "TITLE_YEAR")

  roots <- vapply(seq_len(n), root, integer(1))
  root_levels <- unique(roots)
  work_id <- paste0("WORK-", sprintf("%06d", match(roots, root_levels)))
  record_sources <- dplyr::mutate(records, work_id = work_id, .before = 1)

  works <- record_sources |>
    dplyr::group_by(work_id) |>
    dplyr::summarise(
      title = select_representative_value(title),
      abstract = select_representative_value(abstract),
      authors = select_representative_value(authors),
      year = select_representative_value(year),
      journal = select_representative_value(journal),
      doi = select_representative_value(doi),
      pmid = select_representative_value(pmid),
      wos_ut = select_representative_value(wos_ut),
      scopus_eid = select_representative_value(scopus_eid),
      embase_id = select_representative_value(embase_id),
      source_count = dplyr::n_distinct(source_database),
      original_record_count = dplyr::n(),
      .groups = "drop"
    )

  approximate <- list()
  approximate_index <- 0L
  approximate_eligible <- which(nchar(title_key) >= 20L & nzchar(year_key))
  blocks <- split(
    approximate_eligible,
    paste(year_key[approximate_eligible], substr(title_key[approximate_eligible], 1L, 24L),
          sep = "|")
  )
  for (indices in blocks[lengths(blocks) > 1L]) {
    pairs <- utils::combn(indices, 2L)
    for (column in seq_len(ncol(pairs))) {
      left <- pairs[1L, column]
      right <- pairs[2L, column]
      if (work_id[[left]] == work_id[[right]]) next
      maximum <- max(nchar(title_key[[left]]), nchar(title_key[[right]]))
      if (!maximum) next
      distance <- as.numeric(utils::adist(title_key[[left]], title_key[[right]])) / maximum
      if (distance <= 0.08) {
        approximate_index <- approximate_index + 1L
        approximate[[approximate_index]] <- tibble::tibble(
          candidate_id = sprintf("FUZZY-%06d", approximate_index),
          record_id_1 = records$record_id[[left]],
          record_id_2 = records$record_id[[right]],
          normalized_edit_distance = distance,
          decision = "PENDING_HUMAN_REVIEW", reviewer = NA_character_,
          decision_date = NA_character_, notes = NA_character_
        )
      }
    }
  }

  list(
    works = works,
    records = records,
    work_sources = record_sources |>
      dplyr::select(
        work_id, record_id, source_database, source_record_id, search_line,
        search_strategy_id, search_version, search_date, stream_tags,
        raw_file, raw_batch
      ),
    deduplication_decisions = dplyr::bind_rows(decisions),
    approximate_candidates = dplyr::bind_rows(approximate)
  )
}
