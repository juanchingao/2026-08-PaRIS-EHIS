source("scripts/00_setup.R")

required <- c("pdftools", "xml2", "readr", "dplyr", "tibble", "stringr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "),
       ". Restore or update the renv environment first.", call. = FALSE)
}

methods_dir <- file.path(project_paths$root, "documentation", "methods")
metadata_dir <- project_paths$metadata

w2_file <- file.path(methods_dir, "EHIS wave 2 variables and anonymisation rules.docx.pdf")
w3_file <- file.path(methods_dir, "EHIS wave 3 anonymisation rules.docx")

normalise_text <- function(x) {
  x <- stringr::str_replace_all(x, "[\u00a0\u2007\u202f]", " ")
  x <- stringr::str_squish(x)
  dplyr::na_if(x, "")
}

collapse_unique <- function(x, separator = " || ") {
  x <- normalise_text(x)
  x <- unique(stats::na.omit(x))
  if (!length(x)) NA_character_ else paste(x, collapse = separator)
}

expand_docx_row <- function(row, ns, n_columns) {
  output <- rep(NA_character_, n_columns)
  before <- xml2::xml_find_first(row, "./w:trPr/w:gridBefore", ns)
  position <- if (inherits(before, "xml_missing")) 1L else
    as.integer(xml2::xml_attr(before, "w:val", ns = ns)) + 1L

  cells <- xml2::xml_find_all(row, "./w:tc", ns)
  for (cell in cells) {
    paragraphs <- xml2::xml_find_all(cell, "./w:p", ns)
    paragraph_text <- vapply(paragraphs, function(paragraph) {
      paste(xml2::xml_text(xml2::xml_find_all(paragraph, ".//w:t", ns)), collapse = "")
    }, character(1))
    value <- normalise_text(paste(paragraph_text, collapse = " "))

    span_node <- xml2::xml_find_first(cell, "./w:tcPr/w:gridSpan", ns)
    span <- if (inherits(span_node, "xml_missing")) 1L else
      as.integer(xml2::xml_attr(span_node, "w:val", ns = ns))
    if (is.na(span) || span < 1L) span <- 1L

    if (position <= n_columns) output[position] <- value
    position <- position + span
  }
  output
}

extract_docx_rows <- function(path) {
  extraction_dir <- tempfile("ehis-docx-")
  dir.create(extraction_dir)
  on.exit(unlink(extraction_dir, recursive = TRUE), add = TRUE)
  utils::unzip(path, files = "word/document.xml", exdir = extraction_dir)
  document <- xml2::read_xml(file.path(extraction_dir, "word", "document.xml"))
  ns <- xml2::xml_ns(document)
  tables <- xml2::xml_find_all(document, "//w:tbl", ns)

  extracted <- lapply(seq_along(tables), function(table_index) {
    table <- tables[[table_index]]
    n_columns <- length(xml2::xml_find_all(table, "./w:tblGrid/w:gridCol", ns))
    rows <- xml2::xml_find_all(table, "./w:tr", ns)
    values <- t(vapply(rows, expand_docx_row, character(n_columns), ns = ns,
                       n_columns = n_columns))

    header_index <- which(vapply(rows, function(row) {
      any(xml2::xml_text(xml2::xml_find_all(row, ".//w:t", ns)) == "Variable name")
    }, logical(1)))[1]
    if (is.na(header_index)) stop("Variable header not found in DOCX table.", call. = FALSE)
    header_cells <- xml2::xml_find_all(rows[[header_index]], "./w:tc", ns)
    header_layout <- lapply(header_cells, function(cell) {
      text <- normalise_text(paste(xml2::xml_text(xml2::xml_find_all(cell, ".//w:t", ns)),
                                   collapse = ""))
      span_node <- xml2::xml_find_first(cell, "./w:tcPr/w:gridSpan", ns)
      span <- if (inherits(span_node, "xml_missing")) 1L else
        as.integer(xml2::xml_attr(span_node, "w:val", ns = ns))
      list(text = text, span = ifelse(is.na(span), 1L, span))
    })
    starts <- cumsum(c(1L, vapply(header_layout, `[[`, integer(1), "span")))[
      seq_along(header_layout)]
    ends <- starts + vapply(header_layout, `[[`, integer(1), "span") - 1L
    labels <- vapply(header_layout, `[[`, character(1), "text")

    logical_headers <- c("Variable name", "Description", "Answer categories and codes",
                         "Filter", "Anonymisation rule")
    logical_values <- vapply(logical_headers, function(label) {
      header_position <- match(label, labels)
      if (is.na(header_position)) stop("Missing DOCX header: ", label, call. = FALSE)
      apply(values[, starts[header_position]:ends[header_position], drop = FALSE], 1,
            collapse_unique, separator = " ")
    }, character(nrow(values)))
    logical_values <- as.data.frame(logical_values, stringsAsFactors = FALSE)
    names(logical_values) <- paste0("column_", seq_len(5))
    logical_values$table_number <- table_index
    logical_values$table_row <- seq_len(nrow(logical_values))
    logical_values
  })
  dplyr::bind_rows(extracted)
}

docx_rows_to_variables <- function(rows, source_document) {
  rows <- rows |>
    dplyr::mutate(dplyr::across(dplyr::starts_with("column_"), normalise_text)) |>
    dplyr::filter(column_1 != "Variable name")
  if (!all(paste0("column_", 1:5) %in% names(rows))) {
    stop("Unexpected Wave 3 table structure: five logical columns are required.", call. = FALSE)
  }

  is_variable <- !is.na(rows$column_1) & !is.na(rows$column_2) &
    stringr::str_detect(rows$column_1, "^[A-Z][A-Z0-9_]*$")
  starts <- which(is_variable)

  section <- NA_character_
  sections <- rep(NA_character_, nrow(rows))
  for (index in seq_len(nrow(rows))) {
    remaining <- unlist(rows[index, paste0("column_", 2:5)], use.names = FALSE)
    if (!is.na(rows$column_1[index]) && all(is.na(remaining)) && !is_variable[index]) {
      section <- rows$column_1[index]
    }
    sections[index] <- section
  }

  records <- lapply(seq_along(starts), function(i) {
    first <- starts[i]
    last <- if (i < length(starts)) starts[i + 1L] - 1L else nrow(rows)
    block <- rows[first:last, , drop = FALSE]
    tibble::tibble(
      source_id = "EHIS-W3-ANON-RULES",
      survey = "EHIS",
      wave = "3",
      original_name = rows$column_1[first],
      section = sections[first],
      description = collapse_unique(block$column_2, " "),
      answer_categories_and_codes = collapse_unique(block$column_3),
      filter = collapse_unique(block$column_4, " "),
      anonymisation_rule = collapse_unique(block$column_5, " "),
      source_document = basename(source_document),
      source_location = paste0("table ", rows$table_number[first],
                               ", row ", rows$table_row[first]),
      extraction_method = "OOXML table grid",
      review_status = "EXTRACTED_UNREVIEWED"
    )
  })
  dplyr::bind_rows(records)
}

extract_pdf_variables <- function(path) {
  pages <- pdftools::pdf_data(path)
  records <- list()
  record_index <- 0L

  for (page_number in seq_along(pages)) {
    page <- pages[[page_number]] |>
      dplyr::mutate(text = normalise_text(text))

    minimum_y <- if (page_number == 1L) 110 else 60
    candidates <- page |>
      dplyr::filter(x >= 50, x < 140, y > minimum_y,
                    stringr::str_detect(
                      text,
                      "^[A-Z][A-Z0-9_]*$|^[A-Za-z_]*[0-9][A-Za-z0-9_]*$"
                    ))

    if (nrow(candidates)) {
      same_line_support <- vapply(seq_len(nrow(candidates)), function(i) {
        y_value <- candidates$y[i]
        has_description <- any(page$x >= 145 & page$x < 275 & abs(page$y - y_value) <= 2)
        has_description
      }, logical(1))
      candidates <- candidates[same_line_support, , drop = FALSE]
    }
    if (!nrow(candidates)) next
    candidates <- candidates[order(candidates$y), , drop = FALSE]

    for (i in seq_len(nrow(candidates))) {
      start_y <- candidates$y[i]
      end_y <- if (i < nrow(candidates)) candidates$y[i + 1L] else Inf
      block <- page |>
        dplyr::filter(y >= start_y, y < end_y)

      cell_text <- function(lower, upper = Inf) {
        selected <- block |>
          dplyr::filter(x >= lower, x < upper) |>
          dplyr::arrange(y, x)
        if (!nrow(selected)) return(NA_character_)
        lines <- split(selected, selected$y)
        collapse_unique(vapply(lines, function(line) {
          paste(line$text[order(line$x)], collapse = " ")
        }, character(1)), " ")
      }

      record_index <- record_index + 1L
      records[[record_index]] <- tibble::tibble(
        source_id = "EHIS-W2-ANON-RULES",
        survey = "EHIS",
        wave = "2",
        original_name = candidates$text[i],
        section = NA_character_,
        description = cell_text(145, 275),
        answer_categories_and_codes = cell_text(275, 505),
        filter = cell_text(505, 635),
        anonymisation_rule = cell_text(635),
        source_document = basename(path),
        source_location = paste0("page ", page_number),
        extraction_method = "PDF word coordinates",
        review_status = "EXTRACTED_UNREVIEWED"
      )
    }
  }
  dplyr::bind_rows(records) |>
    dplyr::distinct(wave, original_name, .keep_all = TRUE)
}

if (!file.exists(w2_file)) stop("Wave 2 document not found: ", w2_file, call. = FALSE)
if (!file.exists(w3_file)) stop("Wave 3 document not found: ", w3_file, call. = FALSE)

w2 <- extract_pdf_variables(w2_file)
w3_rows <- extract_docx_rows(w3_file)
w3 <- docx_rows_to_variables(w3_rows, w3_file)
combined <- dplyr::bind_rows(w2, w3) |>
  dplyr::arrange(as.integer(wave), original_name) |>
  dplyr::mutate(source_variable_id = paste(
                  "SRC-EHIS", paste0("W", wave),
                  stringr::str_replace_all(toupper(original_name), "[^A-Z0-9]+", "_"),
                  sep = "-"
                ),
                .before = 1) |>
  dplyr::ungroup()

comparison_fields <- c("description", "answer_categories_and_codes", "filter",
                       "anonymisation_rule")
w2_comparison <- w2 |>
  dplyr::mutate(normalised_name = toupper(original_name)) |>
  dplyr::select(normalised_name, w2_name = original_name,
                dplyr::all_of(comparison_fields)) |>
  dplyr::rename_with(~ paste0("w2_", .x), dplyr::all_of(comparison_fields))
w3_comparison <- w3 |>
  dplyr::mutate(normalised_name = toupper(original_name)) |>
  dplyr::select(normalised_name, w3_name = original_name,
                dplyr::all_of(comparison_fields)) |>
  dplyr::rename_with(~ paste0("w3_", .x), dplyr::all_of(comparison_fields))

comparison <- dplyr::full_join(w2_comparison, w3_comparison, by = "normalised_name") |>
  dplyr::mutate(
    presence = dplyr::case_when(
      !is.na(w2_name) & !is.na(w3_name) ~ "BOTH",
      !is.na(w2_name) ~ "WAVE2_ONLY",
      TRUE ~ "WAVE3_ONLY"
    ),
    description_text_differs = dplyr::if_else(presence == "BOTH",
      w2_description != w3_description, NA),
    categories_text_differs = dplyr::if_else(presence == "BOTH",
      w2_answer_categories_and_codes != w3_answer_categories_and_codes, NA),
    filter_text_differs = dplyr::if_else(presence == "BOTH", w2_filter != w3_filter, NA),
    anonymisation_rule_text_differs = dplyr::if_else(presence == "BOTH",
      w2_anonymisation_rule != w3_anonymisation_rule, NA)
  ) |>
  dplyr::arrange(presence, normalised_name)

readr::write_csv(w2, file.path(metadata_dir, "ehis_wave2_anonymisation_dictionary.csv"),
                 na = "")
readr::write_csv(w3, file.path(metadata_dir, "ehis_wave3_anonymisation_dictionary.csv"),
                 na = "")
readr::write_csv(combined, file.path(metadata_dir, "ehis_anonymisation_dictionary.csv"),
                 na = "")
readr::write_csv(comparison,
                 file.path(metadata_dir, "ehis_wave2_wave3_variable_comparison.csv"),
                 na = "")

message("Extracted ", nrow(w2), " Wave 2 variables and ", nrow(w3),
        " Wave 3 variables.")
