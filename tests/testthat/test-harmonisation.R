source(testthat::test_path("..", "..", "R", "harmonisation.R"))

test_that("controlled vocabularies are stable", {
  expect_setequal(valid_harmonisation_classes(),
                  c("DIRECT", "RECODABLE", "DERIVABLE", "PARTIAL", "RELATED", "NONE"))
  expect_setequal(
    valid_harmonisation_potentials(),
    c("IDENTICAL", "COMPATIBLE", "PARTIALLY_COMPATIBLE", "INCOMPATIBLE",
      "UNAVAILABLE")
  )
  expect_true("UNRESOLVED" %in% valid_review_statuses())
})

test_that("invalid controlled values fail", {
  expect_invisible(validate_controlled_value("DIRECT", valid_harmonisation_classes(), "class"))
  expect_error(validate_controlled_value("SIMILAR", valid_harmonisation_classes(), "class"))
})

test_that("multisource DataSchema templates expose required traceability", {
  root <- testthat::test_path("..", "..")
  domains <- readr::read_csv(
    file.path(root, "harmonisation", "catalogues", "domains.csv"),
    show_col_types = FALSE
  )
  dataschema <- readr::read_csv(
    file.path(root, "harmonisation", "templates", "dataschema-template.csv"),
    show_col_types = FALSE
  )
  equivalence <- readr::read_csv(
    file.path(root, "harmonisation", "templates", "equivalence-matrix-template.csv"),
    show_col_types = FALSE
  )

  expect_equal(nrow(domains), 14L)
  expect_equal(anyDuplicated(domains$domain_id), 0L)
  expect_true(all(c(
    "permitted_analytic_use", "target_population", "missing_value_types",
    "tolerated_information_loss", "version"
  ) %in% names(dataschema)))
  expect_true(all(c(
    "wording_compatibility", "filter_compatibility",
    "questionnaire_context_compatibility", "national_adaptation_compatibility",
    "information_loss", "harmonisation_potential", "technical_class"
  ) %in% names(equivalence)))
})

test_that("multisource scope remains phased and does not overstate data access", {
  root <- testthat::test_path("..", "..")
  surveys <- readr::read_csv(
    file.path(root, "documentation", "inventories", "survey-inventory.csv"),
    show_col_types = FALSE
  )
  decisions <- readr::read_csv(
    file.path(root, "harmonisation", "decisions", "decision_log.csv"),
    show_col_types = FALSE
  )
  strategies <- readr::read_csv(
    file.path(root, "research", "scoping-review", "search-strategies-draft.csv"),
    show_col_types = FALSE
  )
  sentinels <- readr::read_csv(
    file.path(root, "research", "scoping-review", "sentinel-articles.csv"),
    show_col_types = FALSE
  )

  expect_equal(nrow(surveys), 10L)
  expect_equal(surveys$proposed_role[surveys$survey_id == "PARIS-C1"],
               "Index survey")
  expect_equal(surveys$proposed_role[surveys$survey_id == "EHIS-W3"],
               "First comparator")
  expect_false(any(surveys$microdata_access_status == "AVAILABLE"))
  expect_setequal(
    decisions$decision_id[decisions$decision_id %in%
                            sprintf("DEC-2026-%03d", 3:9)],
    sprintf("DEC-2026-%03d", 3:9)
  )
  expect_true(all(
    decisions$status[decisions$decision_id %in%
                       sprintf("DEC-2026-%03d", 3:9)] == "PROPOSED"
  ))
  expect_true(all(strategies$execution_status == "DRAFT_NOT_RUN"))
  expect_true(all(strategies$validation_status == "DRAFT_REQUIRES_VALIDATION"))
  expect_true(all(sentinels$validation_status == "NOT_TESTED"))
  expect_false(any(is.na(sentinels$doi) | sentinels$doi == ""))
})
