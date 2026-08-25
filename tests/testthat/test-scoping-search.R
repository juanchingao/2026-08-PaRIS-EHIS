source(testthat::test_path("..", "..", "R", "bibliographic_search.R"))
source(testthat::test_path("..", "..", "R", "bibliographic_deduplication.R"))
source(testthat::test_path("..", "..", "R", "ris_import.R"))
source(testthat::test_path("..", "..", "R", "bibliographic_corpus.R"))

testthat::test_that("search strategy register contains independent A B C lines", {
  strategies <- load_scoping_search_strategies(testthat::test_path("..", ".."))
  testthat::expect_equal(nrow(strategies), 15L)
  testthat::expect_setequal(unique(strategies$search_line), c("A", "B", "C"))
  counts <- table(strategies$database, strategies$search_line)
  testthat::expect_true(all(counts == 1L))
  testthat::expect_true(all(strategies$status %in% valid_search_strategy_states()))
})

testthat::test_that("bibliographic schema is completed without losing provenance", {
  input <- tibble::tibble(
    record_id = "PUBMED-1-A", source_database = "PubMed/MEDLINE",
    source_record_id = "1", search_line = "A", search_strategy_id = "TEST-A",
    search_version = "0.0", search_date = "2026-08-25", title = "Example"
  )
  result <- conform_bibliographic_schema(input)
  testthat::expect_identical(names(result), bibliographic_schema())
  testthat::expect_equal(result$source_record_id, "1")
  testthat::expect_true(is.na(result$raw_file))
})

testthat::test_that("exact deduplication retains all original source rows", {
  records <- tibble::tibble(
    record_id = c("P-1-A", "S-1-A", "E-1-B", "P-2-C"),
    source_database = c("PubMed/MEDLINE", "Scopus", "Embase", "PubMed/MEDLINE"),
    source_record_id = c("1", "S1", "E1", "2"),
    search_line = c("A", "A", "B", "C"),
    search_strategy_id = c("P-A", "S-A", "E-B", "P-C"),
    search_version = "0.0", search_date = "2026-08-25",
    title = c("The same study", "The same study", "A third title", "Different"),
    year = c("2020", "2020", "2021", "2022"),
    doi = c("https://doi.org/10.1/ABC", "doi:10.1/abc", NA, NA),
    pmid = c("1", NA, "3", "2")
  ) |>
    conform_bibliographic_schema()
  corpus <- build_bibliographic_corpus(records)
  testthat::expect_equal(nrow(corpus$records), 4L)
  testthat::expect_equal(nrow(corpus$work_sources), 4L)
  testthat::expect_equal(nrow(corpus$works), 3L)
  testthat::expect_equal(
    corpus$work_sources$work_id[corpus$work_sources$record_id == "P-1-A"],
    corpus$work_sources$work_id[corpus$work_sources$record_id == "S-1-A"]
  )
  testthat::expect_true("DOI" %in% corpus$deduplication_decisions$rule)
})

testthat::test_that("approximate title matches are not merged silently", {
  records <- tibble::tibble(
    record_id = c("A", "B"), source_database = c("Scopus", "Embase"),
    source_record_id = c("A", "B"), search_line = c("A", "A"),
    search_strategy_id = c("S-A", "E-A"), search_version = "0.0",
    search_date = "2026-08-25",
    title = c("Retrospective data harmonization methods",
              "Retrospective data harmonisation methods"),
    year = c("2020", "2020")
  ) |>
    conform_bibliographic_schema()
  corpus <- build_bibliographic_corpus(records)
  testthat::expect_equal(nrow(corpus$works), 2L)
  testthat::expect_equal(nrow(corpus$approximate_candidates), 1L)
  testthat::expect_equal(
    corpus$approximate_candidates$decision, "PENDING_HUMAN_REVIEW"
  )
})

testthat::test_that("HTTP messages redact credentials", {
  message <- paste0(
    "api_key=", "secret", " token:", "abc",
    " authorization=", "Bearer-value"
  )
  clean <- sanitise_http_message(message)
  testthat::expect_false(grepl("secret|abc|Bearer-value", clean, ignore.case = TRUE))
  testthat::expect_true(grepl("REDACTED", clean))
})
