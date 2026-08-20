source(testthat::test_path("..", "..", "R", "harmonisation.R"))

test_that("controlled vocabularies are stable", {
  expect_setequal(valid_harmonisation_classes(),
                  c("DIRECT", "RECODABLE", "DERIVABLE", "PARTIAL", "RELATED", "NONE"))
  expect_true("UNRESOLVED" %in% valid_review_statuses())
})

test_that("invalid controlled values fail", {
  expect_invisible(validate_controlled_value("DIRECT", valid_harmonisation_classes(), "class"))
  expect_error(validate_controlled_value("SIMILAR", valid_harmonisation_classes(), "class"))
})
