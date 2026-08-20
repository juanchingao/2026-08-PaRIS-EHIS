test_that("narrative review strategies are machine readable", {
  review_dir <- testthat::test_path("..", "..", "research", "narrative-review")
  strategies <- readr::read_csv(
    file.path(review_dir, "search-strategies.csv"),
    show_col_types = FALSE
  )
  expect_true(nrow(strategies) >= 5)
  expect_equal(sum(strategies$database == "PubMed"), 3)
  expect_equal(anyDuplicated(strategies$strategy_id), 0L)
  expect_true(all(c("query", "objective", "status") %in% names(strategies)))
})

test_that("review extraction templates have stable identifiers", {
  review_dir <- testthat::test_path("..", "..", "research", "narrative-review")
  screening <- readr::read_csv(
    file.path(review_dir, "screening.csv"),
    show_col_types = FALSE
  )
  extraction <- readr::read_csv(
    file.path(review_dir, "evidence-extraction.csv"),
    show_col_types = FALSE
  )
  expect_true("record_id" %in% names(screening))
  expect_true("record_id" %in% names(extraction))
  expect_true(all(c("paris_ehis_implication", "disposition") %in% names(extraction)))
})

test_that("initial narrative screening is complete and controlled", {
  review_dir <- testthat::test_path("..", "..", "research", "narrative-review")
  reviewed <- readr::read_csv(
    file.path(review_dir, "reviewed-screening.csv"), show_col_types = FALSE
  )
  expect_equal(nrow(reviewed), 121)
  expect_false(anyDuplicated(reviewed$record_id) > 0)
  expect_setequal(unique(reviewed$decision), c("INCLUDE", "BACKGROUND", "EXCLUDE"))
  expect_equal(sum(reviewed$decision == "INCLUDE"), 35)
  expect_equal(sum(reviewed$decision == "BACKGROUND"), 29)
  expect_equal(sum(reviewed$decision == "EXCLUDE"), 57)
  expect_false(any(is.na(reviewed$reason) | reviewed$reason == ""))
})

test_that("included evidence is tiered and core sources are extracted", {
  review_dir <- testthat::test_path("..", "..", "research", "narrative-review")
  evidence_map <- readr::read_csv(
    file.path(review_dir, "evidence-map.csv"), show_col_types = FALSE
  )
  extraction <- readr::read_csv(
    file.path(review_dir, "evidence-extraction.csv"), show_col_types = FALSE
  )
  expect_equal(nrow(evidence_map), 35)
  expect_equal(sum(evidence_map$evidence_tier == "CORE"), 15)
  expect_equal(sum(evidence_map$evidence_tier == "APPLIED"), 10)
  expect_equal(sum(evidence_map$evidence_tier == "SPECIALISED"), 10)
  expect_equal(nrow(extraction), 15)
  expect_setequal(extraction$record_id, evidence_map$record_id[evidence_map$evidence_tier == "CORE"])
})
