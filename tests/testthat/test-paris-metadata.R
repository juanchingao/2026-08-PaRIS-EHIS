metadata_dir <- testthat::test_path("..", "..", "data", "metadata")
paris_dictionary <- readr::read_csv(
  file.path(metadata_dir, "paris_cycle1_puf_dictionary.csv"),
  show_col_types = FALSE
)
paris_value_labels <- readr::read_csv(
  file.path(metadata_dir, "paris_cycle1_puf_value_labels.csv"),
  show_col_types = FALSE
)

test_that("PaRIS codebook has expected coverage", {
  expect_equal(nrow(paris_dictionary), 195)
  expect_equal(nrow(paris_value_labels), 1302)
  expect_true(all(paris_dictionary$codebook_match_status == "MATCHED"))
})

test_that("PaRIS variable identifiers and names are unique", {
  expect_false(anyDuplicated(paris_dictionary$source_variable_id) > 0)
  expect_false(anyDuplicated(toupper(paris_dictionary$original_name)) > 0)
})

test_that("PaRIS value labels retain variable-level missingness", {
  expect_true(is.logical(paris_value_labels$is_missing_category))
  expect_equal(sum(paris_value_labels$is_missing_category), 492)
  expect_true(all(c("-97", "-96", "-95", ".a", ".d") %in%
                    paris_value_labels$answer_code))
})

test_that("mandatory PaRIS metadata are complete", {
  mandatory <- c("source_variable_id", "source_id", "survey", "cycle",
                 "original_name", "population_asked", "variable_type",
                 "variable_label", "source_document", "dictionary_source_row",
                 "review_status")
  expect_true(all(mandatory %in% names(paris_dictionary)))
  expect_false(any(is.na(paris_dictionary[mandatory])))
  expect_true(all(paris_dictionary$review_status == "EXTRACTED_UNREVIEWED"))
})
