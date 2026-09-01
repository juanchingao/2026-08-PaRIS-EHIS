source(testthat::test_path("..", "..", "R", "bibliographic_search.R"))
source(testthat::test_path("..", "..", "R", "bibliographic_deduplication.R"))
source(testthat::test_path("..", "..", "R", "ris_import.R"))
source(testthat::test_path("..", "..", "R", "bibliographic_corpus.R"))
source(testthat::test_path("..", "..", "R", "wos_starter.R"))

testthat::test_that("WP1 evidence streams and historical aliases remain separate", {
  root <- testthat::test_path("..", "..")
  master <- readr::read_csv(
    file.path(root, "research", "scoping-review", "strategies",
              "master-search-register.csv"), show_col_types = FALSE
  )
  aliases <- readr::read_csv(
    file.path(root, "research", "scoping-review", "strategies",
              "search-id-crosswalk.csv"), show_col_types = FALSE
  )
  testthat::expect_setequal(
    unique(master$work_package), c("WP1A", "WP1B", "WP1B-FUTURE")
  )
  testthat::expect_true(all(c("NR-PUBMED-01", "NR-PUBMED-02") %in%
                              aliases$historical_search_id))
  testthat::expect_true(all(aliases$historical_results_changed == FALSE))
  testthat::expect_true(all(master$status %in% c(
    "DRAFT", "PILOTED", "READY", "EXECUTED", "SUPERSEDED",
    "REQUIRES_REVIEW"
  )))
})

testthat::test_that("WoS Starter normalization retains UT and separate keyword fields", {
  strategy <- list(
    search_strategy_id = "WP1A-WOS-01", search_line = "WP1A",
    query_version = "1.0", stream_tags = "WP1A_METHODS"
  )
  hits <- list(list(
    uid = "WOS:0001", title = "Example", identifiers = list(doi = "10.1/a"),
    names = list(authors = list(displayName = "A. Author")),
    source = list(sourceTitle = "Journal", publishYear = 2026),
    keywords = list(authorKeywords = c("harmonisation", "survey"),
                    keywordsPlus = c("methods")), types = "Article"
  ))
  result <- normalise_wos_hits(hits, strategy, "raw/page.json",
                               "2026-09-01T00:00:00Z")
  testthat::expect_equal(result$wos_ut, "WOS:0001")
  testthat::expect_match(result$keywords, "harmonisation")
  testthat::expect_match(result$keywords_plus, "methods")
  testthat::expect_equal(result$stream_tags, "WP1A_METHODS")
})

testthat::test_that("WoS UT is an exact conservative deduplication rule", {
  records <- tibble::tibble(
    record_id = c("W1", "W2"), source_database = "Web of Science Core Collection",
    source_record_id = "WOS:1", search_line = c("WP1A", "WP1A"),
    search_strategy_id = c("WP1A-WOS-01", "WP1A-WOS-02"),
    search_version = "1.0", search_date = "2026-09-01",
    title = c("Different supplied title", "Another supplied title"),
    wos_ut = "WOS:1"
  ) |>
    conform_bibliographic_schema()
  corpus <- build_bibliographic_corpus(records)
  testthat::expect_equal(nrow(corpus$works), 1L)
  testthat::expect_true("WOS_UT" %in% corpus$deduplication_decisions$rule)
})

testthat::test_that("search strategy register contains independent A B C lines", {
  strategies <- load_scoping_search_strategies(testthat::test_path("..", ".."))
  testthat::expect_equal(nrow(strategies), 15L)
  testthat::expect_setequal(unique(strategies$search_line), c("A", "B", "C"))
  counts <- table(strategies$database, strategies$search_line)
  testthat::expect_true(all(counts == 1L))
  testthat::expect_true(all(strategies$status %in% valid_search_strategy_states()))
  testthat::expect_false(any(grepl("\\\\", strategies$query)))
})

testthat::test_that("manual Embase and Web of Science exports are pre-registered", {
  root <- testthat::test_path("..", "..")
  manifest <- readr::read_csv(
    file.path(root, "research", "scoping-review", "manifests", "manual-exports.csv"),
    show_col_types = FALSE
  )
  testthat::expect_equal(nrow(manifest), 9L)
  testthat::expect_setequal(unique(manifest$search_line), c("A", "B", "C"))
  testthat::expect_setequal(
    unique(manifest$database),
    c("Embase", "APA PsycINFO", "Web of Science Core Collection")
  )
  testthat::expect_true(all(manifest$status == "PENDING_UPLOAD"))
  testthat::expect_equal(anyDuplicated(manifest$import_id), 0L)
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
