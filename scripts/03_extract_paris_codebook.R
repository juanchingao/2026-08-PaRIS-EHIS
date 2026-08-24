source("scripts/00_setup.R")

required <- c("xml2", "readr", "dplyr", "tibble", "stringr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "),
       ". Restore the renv environment first.", call. = FALSE)
}

source_file <- file.path(
  project_paths$raw, "documentation", "paris",
  "paris-cycle1-puf-codebook-202605-v0.xlsx"
)
source_id <- "PARIS-C1-PUF202605-CODEBOOK"

normalise_text <- function(x) {
  x <- stringr::str_replace_all(x, "[\u00a0\u2007\u202f]", " ")
  x <- stringr::str_squish(x)
  dplyr::na_if(x, "")
}

collapse_unique <- function(x, separator = " || ") {
  x <- unique(stats::na.omit(normalise_text(x)))
  if (!length(x)) NA_character_ else paste(x, collapse = separator)
}

excel_column_number <- function(reference) {
  letters <- strsplit(gsub("[0-9]", "", reference), "")[[1]]
  Reduce(function(total, letter) total * 26L + match(letter, LETTERS), letters,
         init = 0L)
}

read_xlsx_ooxml <- function(path) {
  extraction_dir <- tempfile("paris-xlsx-")
  dir.create(extraction_dir)
  on.exit(unlink(extraction_dir, recursive = TRUE), add = TRUE)
  utils::unzip(path, exdir = extraction_dir)

  main_ns <- c(x = "http://schemas.openxmlformats.org/spreadsheetml/2006/main")
  rel_ns <- c(r = "http://schemas.openxmlformats.org/package/2006/relationships")
  office_rel_ns <- c(
    r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  )

  shared_path <- file.path(extraction_dir, "xl", "sharedStrings.xml")
  shared <- character()
  if (file.exists(shared_path)) {
    shared_xml <- xml2::read_xml(shared_path)
    shared <- vapply(xml2::xml_find_all(shared_xml, "//x:si", main_ns), function(node) {
      paste(xml2::xml_text(xml2::xml_find_all(node, ".//x:t", main_ns)), collapse = "")
    }, character(1))
  }

  workbook <- xml2::read_xml(file.path(extraction_dir, "xl", "workbook.xml"))
  relationships <- xml2::read_xml(
    file.path(extraction_dir, "xl", "_rels", "workbook.xml.rels")
  )
  relationship_nodes <- xml2::xml_find_all(relationships, "//r:Relationship", rel_ns)
  relationship_map <- stats::setNames(xml2::xml_attr(relationship_nodes, "Target"),
                                      xml2::xml_attr(relationship_nodes, "Id"))

  sheet_nodes <- xml2::xml_find_all(workbook, "//x:sheets/x:sheet", main_ns)
  output <- list()
  for (sheet in sheet_nodes) {
    sheet_name <- xml2::xml_attr(sheet, "name")
    relationship_id <- unname(xml2::xml_attrs(sheet)["id"])
    target <- relationship_map[[relationship_id]]
    sheet_path <- file.path(extraction_dir, "xl", gsub("^/", "", target))
    sheet_xml <- xml2::read_xml(sheet_path)
    row_nodes <- xml2::xml_find_all(sheet_xml, "//x:sheetData/x:row", main_ns)
    max_column <- max(vapply(xml2::xml_find_all(sheet_xml, "//x:sheetData/x:row/x:c", main_ns),
                             function(cell) excel_column_number(xml2::xml_attr(cell, "r")),
                             integer(1)))
    values <- matrix(NA_character_, nrow = length(row_nodes), ncol = max_column)
    source_rows <- integer(length(row_nodes))

    for (row_index in seq_along(row_nodes)) {
      row <- row_nodes[[row_index]]
      source_rows[row_index] <- as.integer(xml2::xml_attr(row, "r"))
      cells <- xml2::xml_find_all(row, "./x:c", main_ns)
      for (cell in cells) {
        column <- excel_column_number(xml2::xml_attr(cell, "r"))
        type <- xml2::xml_attr(cell, "t")
        value_node <- xml2::xml_find_first(cell, "./x:v", main_ns)
        value <- if (identical(type, "s") && !inherits(value_node, "xml_missing")) {
          shared[as.integer(xml2::xml_text(value_node)) + 1L]
        } else if (identical(type, "inlineStr")) {
          paste(xml2::xml_text(xml2::xml_find_all(cell, ".//x:is/x:t", main_ns)),
                collapse = "")
        } else if (!inherits(value_node, "xml_missing")) {
          xml2::xml_text(value_node)
        } else {
          NA_character_
        }
        values[row_index, column] <- normalise_text(value)
      }
    }

    headers <- values[1, ]
    keep_columns <- which(!is.na(headers))
    data <- as.data.frame(values[-1, keep_columns, drop = FALSE], stringsAsFactors = FALSE)
    names(data) <- headers[keep_columns] |>
      trimws() |>
      tolower() |>
      stringr::str_replace_all("[^a-z0-9]+", "_") |>
      stringr::str_replace_all("^_|_$", "")
    data$source_row <- source_rows[-1]
    output[[sheet_name]] <- data
  }
  output
}

if (!file.exists(source_file)) stop("PaRIS codebook not found: ", source_file, call. = FALSE)
workbook <- read_xlsx_ooxml(source_file)
required_sheets <- c("PUF_DataDictionary", "PUF_MSPatient Codebook")
if (!all(required_sheets %in% names(workbook))) {
  stop("Expected sheets not found: ", paste(setdiff(required_sheets, names(workbook)),
                                            collapse = ", "), call. = FALSE)
}

dictionary_raw <- workbook[["PUF_DataDictionary"]] |>
  dplyr::filter(!is.na(variable_name),
                !is.na(population_asked) | !is.na(variable_type) | !is.na(variable_label)) |>
  dplyr::mutate(variable_key = toupper(variable_name),
                dictionary_source_row = source_row)

codebook_raw <- workbook[["PUF_MSPatient Codebook"]]
block_starts <- which(
  !is.na(codebook_raw$variable_name) &
    (!is.na(codebook_raw$variable_label) | !is.na(codebook_raw$variable_type) |
       !is.na(codebook_raw$answer_values) | !is.na(codebook_raw$answer_code))
)
codebook_metadata <- vector("list", length(block_starts))
value_labels <- vector("list", length(block_starts))

for (i in seq_along(block_starts)) {
  first <- block_starts[i]
  last <- if (i < length(block_starts)) block_starts[i + 1L] - 1L else nrow(codebook_raw)
  block <- codebook_raw[first:last, , drop = FALSE]
  variable_name <- codebook_raw$variable_name[first]
  source_variable_id <- paste0(
    "SRC-PARIS-C1-",
    stringr::str_replace_all(toupper(variable_name), "[^A-Z0-9]+", "_")
  )

  codebook_metadata[[i]] <- tibble::tibble(
    variable_key = toupper(variable_name),
    codebook_name = variable_name,
    country_specific_notes = collapse_unique(block$country_specific_notes),
    codebook_label = collapse_unique(block$variable_label, " "),
    codebook_variable_type = collapse_unique(block$variable_type, " "),
    codebook_remarks = collapse_unique(block$remarks, " "),
    codebook_source_row = codebook_raw$source_row[first]
  )

  categories <- block |>
    dplyr::filter(!is.na(answer_values) | !is.na(answer_code)) |>
    dplyr::transmute(
      source_variable_id = source_variable_id,
      variable_name = variable_name,
      answer_value = answer_values,
      answer_code = answer_code,
      source_id = source_id,
      source_sheet = "PUF_MSPatient Codebook",
      source_row = source_row,
      review_status = "EXTRACTED_UNREVIEWED"
    )
  value_labels[[i]] <- categories
}

codebook_metadata <- dplyr::bind_rows(codebook_metadata)
value_labels <- dplyr::bind_rows(value_labels) |>
  dplyr::mutate(
    is_missing_category = stringr::str_detect(
      stringr::str_to_lower(dplyr::coalesce(answer_value, "")),
      "not answered|multiple answers|question not asked|not stated|refusal|don't know|do not know|^na$"
    ) | dplyr::coalesce(suppressWarnings(as.numeric(answer_code) < 0), FALSE)
  )

dictionary <- dictionary_raw |>
  dplyr::left_join(codebook_metadata, by = "variable_key") |>
  dplyr::mutate(
    source_variable_id = paste0(
      "SRC-PARIS-C1-",
      stringr::str_replace_all(toupper(variable_name), "[^A-Z0-9]+", "_")
    ),
    source_id = source_id,
    survey = "PaRIS",
    cycle = "1",
    source_document = basename(source_file),
    source_sheet = "PUF_DataDictionary",
    codebook_match_status = dplyr::if_else(is.na(codebook_name), "DICTIONARY_ONLY", "MATCHED"),
    review_status = "EXTRACTED_UNREVIEWED"
  ) |>
  dplyr::select(
    source_variable_id, source_id, survey, cycle, original_name = variable_name,
    population_asked, variable_type, variable_label, answer_values_and_codes,
    missing_n, missing_pct, distinct_n, min, max, example,
    country_specific_notes, codebook_name, codebook_label, codebook_variable_type,
    codebook_remarks, codebook_match_status, source_document, source_sheet,
    dictionary_source_row, codebook_source_row, review_status
  )

codebook_only <- codebook_metadata |>
  dplyr::filter(!variable_key %in% dictionary_raw$variable_key)

readr::write_csv(dictionary,
                 file.path(project_paths$metadata, "paris_cycle1_puf_dictionary.csv"), na = "")
readr::write_csv(value_labels,
                 file.path(project_paths$metadata, "paris_cycle1_puf_value_labels.csv"), na = "")
readr::write_csv(codebook_only,
                 file.path(project_paths$metadata, "paris_cycle1_codebook_only_variables.csv"),
                 na = "")

message("Extracted ", nrow(dictionary), " PaRIS dictionary variables, ",
        nrow(value_labels), " value-label rows, and ", nrow(codebook_only),
        " codebook-only variables.")
