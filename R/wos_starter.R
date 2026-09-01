wos_starter_endpoint <- function() {
  "https://api.clarivate.com/apis/wos-starter/v1/documents"
}

`%or%` <- function(left, right) {
  if (is.null(left) || !length(left)) right else left
}

sha256_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

wos_starter_key <- function(variable = "WOS_API_KEY_STARTER_SERMAS") {
  key <- Sys.getenv(variable, unset = "")
  if (!nzchar(key)) {
    stop(variable, " is not configured.", call. = FALSE)
  }
  key
}

wos_starter_request <- function(query, page = 1L, limit = 50L,
                                sort_field = "PY+A", key = NULL,
                                attempts = 3L) {
  if (is.null(key)) key <- wos_starter_key()
  request <- httr2::request(wos_starter_endpoint()) |>
    httr2::req_headers(`X-ApiKey` = key) |>
    httr2::req_url_query(q = query, db = "WOS", page = page, limit = limit,
                         sortField = sort_field) |>
    httr2::req_user_agent("PaRISEHIS-WP1/0.1") |>
    httr2::req_retry(
      max_tries = attempts,
      backoff = function(tries) min(2^(tries - 1L), 8),
      is_transient = function(response) {
        httr2::resp_status(response) == 429L ||
          httr2::resp_status(response) >= 500L
      }
    )
  response <- tryCatch(
    httr2::req_perform(request),
    httr2_http = function(error) error$resp,
    httr2_failure = function(error) error
  )
  if (!inherits(response, "httr2_response")) {
    stop("WoS Starter transport failure: ",
         sanitise_http_message(conditionMessage(response)), call. = FALSE)
  }
  status <- httr2::resp_status(response)
  request_id <- httr2::resp_header(response, "x-request-id")
  if (status >= 400L) {
    diagnosis <- switch(
      as.character(status),
      `401` = "invalid or missing API key",
      `403` = "API plan or database permission denied",
      `429` = "rate limit exhausted",
      if (status >= 500L) "Clarivate server error" else "request rejected"
    )
    stop(sprintf(
      "WoS Starter HTTP %s; endpoint=%s; request_id=%s; operation=documents search; diagnosis=%s",
      status, wos_starter_endpoint(), ifelse(is.null(request_id), "unavailable", request_id),
      diagnosis
    ), call. = FALSE)
  }
  list(
    status = status,
    request_id = request_id,
    body = httr2::resp_body_json(response, simplifyVector = FALSE)
  )
}

wos_scalar <- function(x, default = NA_character_) {
  if (is.null(x) || !length(x)) return(default)
  value <- unlist(x, recursive = TRUE, use.names = FALSE)
  value <- value[!is.na(value) & nzchar(as.character(value))]
  if (!length(value)) default else paste(unique(as.character(value)), collapse = "; ")
}

wos_named_value <- function(x, patterns) {
  if (is.null(x)) return(NA_character_)
  values <- unlist(x, recursive = TRUE, use.names = TRUE)
  names_lower <- tolower(names(values))
  matched <- Reduce(`|`, lapply(patterns, grepl, x = names_lower, fixed = TRUE))
  wos_scalar(values[matched])
}

wos_starter_metadata <- function(body) {
  metadata <- body$metadata
  list(
    total = as.integer(metadata$total %or% 0L),
    page = as.integer(metadata$page %or% 1L),
    limit = as.integer(metadata$limit %or% 0L)
  )
}

wos_starter_hits <- function(body) {
  hits <- body$hits
  if (is.null(hits)) list() else hits
}

normalise_wos_hits <- function(hits, strategy, raw_file, retrieved_at) {
  rows <- lapply(hits, function(hit) {
    uid <- wos_scalar(hit$uid)
    identifiers <- hit$identifiers
    hit_keywords <- hit$keywords
    tibble::tibble(
      record_id = paste0("WOS-", gsub("[^A-Za-z0-9]", "", uid), "-",
                         strategy$search_strategy_id),
      source_database = "Web of Science Core Collection",
      source_record_id = uid,
      search_line = strategy$search_line,
      search_strategy_id = strategy$search_strategy_id,
      search_version = strategy$query_version,
      search_date = substr(retrieved_at, 1L, 10L),
      title = wos_scalar(hit$title),
      abstract = wos_scalar(hit$abstract),
      authors = wos_named_value(hit$names %or% hit$authors,
                                c("author", "displayname", "wosstandard")),
      affiliations = wos_scalar(hit$addresses %or% hit$affiliations),
      year = wos_named_value(hit$source %or% hit$year,
                             c("publishyear", "year")),
      publication_date = wos_named_value(hit$source, c("publishdate")),
      journal = wos_named_value(hit$source %or% hit$sourceTitle,
                                c("sourcetitle", "title")),
      doi = wos_named_value(identifiers, c("doi")),
      pmid = wos_named_value(identifiers, c("pmid")),
      wos_ut = uid,
      scopus_eid = NA_character_,
      embase_id = NA_character_,
      keywords = wos_named_value(hit_keywords, c("author")),
      keywords_plus = wos_named_value(hit_keywords, c("plus")),
      controlled_terms = NA_character_,
      document_type = wos_scalar(hit$types %or% hit$documentType),
      language = wos_named_value(hit$source %or% hit$language, c("language")),
      funding = wos_scalar(hit$funding),
      citation_count = wos_scalar(hit$citations),
      raw_file = raw_file,
      raw_batch = basename(raw_file),
      stream_tags = strategy$stream_tags
    )
  })
  dplyr::bind_rows(rows)
}

write_json_atomic <- function(value, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- paste0(path, ".tmp")
  jsonlite::write_json(value, temporary, auto_unbox = TRUE, pretty = TRUE,
                       null = "null", na = "null")
  if (!file.rename(temporary, path)) {
    stop("Could not finalize file: ", path, call. = FALSE)
  }
  invisible(path)
}

run_wos_starter_search <- function(strategy, paths, pilot = FALSE,
                                   pilot_pages = 1L, resume = TRUE) {
  timestamp <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
  retrieved_at <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  run_id <- paste(strategy$search_strategy_id, strategy$query_version, timestamp,
                  sep = "-")
  raw_dir <- file.path(paths$raw, "scoping-review", "wos", run_id)
  interim_dir <- file.path(paths$interim, "scoping-review", "wos")
  checkpoint_path <- file.path(raw_dir, "checkpoint.json")
  dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
  first <- wos_starter_request(strategy$query, page = 1L, limit = 50L)
  metadata <- wos_starter_metadata(first$body)
  expected_pages <- if (metadata$total) ceiling(metadata$total / 50L) else 0L
  pages_to_fetch <- if (pilot) min(expected_pages, pilot_pages) else expected_pages
  records <- list()
  seen_ut <- character()
  start_page <- 1L
  if (resume && file.exists(checkpoint_path)) {
    checkpoint <- jsonlite::read_json(checkpoint_path, simplifyVector = TRUE)
    start_page <- as.integer(checkpoint$next_page)
    seen_ut <- checkpoint$seen_ut
  }
  for (page in seq.int(start_page, max(1L, pages_to_fetch))) {
    response <- if (page == 1L) first else
      wos_starter_request(strategy$query, page = page, limit = 50L)
    raw_name <- sprintf("page-%05d.json", page)
    raw_path <- file.path(raw_dir, raw_name)
    write_json_atomic(response$body, raw_path)
    hits <- wos_starter_hits(response$body)
    normalized <- normalise_wos_hits(
      hits, strategy, relative_project_path(raw_path), retrieved_at
    )
    if (nrow(normalized)) {
      normalized <- normalized[!normalized$wos_ut %in% seen_ut, , drop = FALSE]
      seen_ut <- unique(c(seen_ut, normalized$wos_ut))
      records[[length(records) + 1L]] <- normalized
    }
    write_json_atomic(list(
      run_id = run_id, next_page = page + 1L, seen_ut = seen_ut,
      updated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    ), checkpoint_path)
  }
  normalized <- dplyr::bind_rows(records) |>
    dplyr::distinct(wos_ut, .keep_all = TRUE)
  normalized_path <- file.path(interim_dir, paste0(run_id, ".csv"))
  dir.create(interim_dir, recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(normalized, normalized_path, na = "")
  raw_files <- list.files(raw_dir, pattern = "^page-.*[.]json$", full.names = TRUE)
  manifest <- list(
    run_id = run_id,
    search_id = strategy$search_strategy_id,
    query_version = strategy$query_version,
    database = "Web of Science Core Collection",
    api_type = "Web of Science Starter API",
    endpoint = wos_starter_endpoint(),
    query = strategy$query,
    timestamp_utc = retrieved_at,
    total_reported = metadata$total,
    total_retrieved = nrow(normalized),
    pages_expected = expected_pages,
    pages_retrieved = length(raw_files),
    complete = !pilot && nrow(normalized) == metadata$total,
    pilot = pilot,
    raw_files = lapply(raw_files, function(path) list(
      path = relative_project_path(path), sha256 = sha256_file(path)
    )),
    normalized_file = relative_project_path(normalized_path),
    normalized_sha256 = sha256_file(normalized_path),
    software_version = paste0("R ", getRversion()),
    git_commit = git_run_state()$commit,
    warnings = if (pilot) "Pilot retrieval only" else character()
  )
  manifest_path <- file.path(raw_dir, "manifest.json")
  write_json_atomic(manifest, manifest_path)
  list(manifest = manifest, manifest_path = manifest_path, records = normalized)
}
