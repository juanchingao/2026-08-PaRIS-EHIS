metadata_dir <- testthat::test_path("..", "..", "data", "metadata")
ehis_dictionary <- readr::read_csv(
  file.path(metadata_dir, "ehis_anonymisation_dictionary.csv"),
  show_col_types = FALSE
)

test_that("EHIS anonymisation dictionaries have expected coverage", {
  expect_equal(sum(ehis_dictionary$wave == "2"), 151)
  expect_equal(sum(ehis_dictionary$wave == "3"), 154)
  expect_equal(nrow(ehis_dictionary), 305)
})

test_that("EHIS source variable identifiers and names are unique", {
  expect_false(anyDuplicated(ehis_dictionary$source_variable_id) > 0)
  expect_false(anyDuplicated(paste(ehis_dictionary$wave,
                                   toupper(ehis_dictionary$original_name))) > 0)
})

test_that("mandatory extracted metadata are complete", {
  mandatory <- c("source_id", "survey", "wave", "original_name", "description",
                 "answer_categories_and_codes", "filter", "anonymisation_rule",
                 "source_document", "source_location", "review_status")
  expect_true(all(mandatory %in% names(ehis_dictionary)))
  expect_false(any(is.na(ehis_dictionary[mandatory])))
  expect_true(all(ehis_dictionary$review_status == "EXTRACTED_UNREVIEWED"))
})
