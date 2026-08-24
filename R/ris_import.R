parse_ris_file <- function(path, strategy_id = NA_character_) {
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  starts <- which(grepl("^TY  -", lines))
  ends <- which(grepl("^ER  -", lines))
  if (!length(starts) || length(starts) != length(ends) || any(ends < starts)) {
    stop("Invalid or incomplete RIS records in: ", basename(path), call. = FALSE)
  }

  parse_record <- function(record_lines) {
    fields <- list()
    current_tag <- NULL
    for (line in record_lines) {
      match <- regexec("^([A-Z0-9]{2})  - ?(.*)$", line)
      parts <- regmatches(line, match)[[1]]
      if (length(parts)) {
        current_tag <- parts[[2]]
        fields[[current_tag]] <- c(fields[[current_tag]], parts[[3]])
      } else if (!is.null(current_tag) && nzchar(trimws(line))) {
        last <- length(fields[[current_tag]])
        fields[[current_tag]][[last]] <- paste(fields[[current_tag]][[last]], trimws(line))
      }
    }
    value <- function(tag, collapse = "; ") {
      values <- fields[[tag]]
      if (is.null(values)) NA_character_ else paste(values, collapse = collapse)
    }
    data.frame(
      embase_id = value("U2"),
      pmid = value("C5"),
      doi = value("DO"),
      title = value("T1"),
      abstract = if (!is.na(value("AB"))) {
        value("AB", collapse = " ")
      } else {
        value("N2", collapse = " ")
      },
      authors = value("A1"),
      journal = value("JF"),
      year = suppressWarnings(as.integer(value("Y1"))),
      publication_type = value("M3"),
      database = value("DB"),
      keywords = value("KW"),
      embase_url = value("UR"),
      stringsAsFactors = FALSE
    )
  }

  records <- lapply(seq_along(starts), function(i) {
    parse_record(lines[starts[[i]]:ends[[i]]])
  })
  result <- do.call(rbind, records)
  result$strategy_id <- strategy_id
  result$source_file <- basename(path)
  result
}
