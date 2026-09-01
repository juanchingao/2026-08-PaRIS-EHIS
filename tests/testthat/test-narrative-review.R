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

test_that("WP1 scoping review remains prospective and machine readable", {
  root <- testthat::test_path("..", "..")
  review_dir <- file.path(root, "research", "scoping-review")
  strategies <- readr::read_csv(
    file.path(review_dir, "search-strategies-draft.csv"),
    show_col_types = FALSE
  )
  extraction <- readr::read_csv(
    file.path(review_dir, "extraction-template.csv"),
    show_col_types = FALSE
  )
  coverage <- readr::read_csv(
    file.path(review_dir, "concept-coverage.csv"),
    show_col_types = FALSE
  )

  expect_true(all(strategies$execution_status == "DRAFT_NOT_RUN"))
  expect_equal(anyDuplicated(strategies$strategy_id), 0L)
  expect_true(all(c("dataschema_definition", "equivalence_criteria",
                    "survey_design_handling", "code_available") %in%
                  names(extraction)))
  expect_true(all(c("differential item functioning", "transportability",
                    "PROMs and PREMs") %in% coverage$concept_label))
})

test_that("bibliographic identifiers are normalised before matching", {
  source(testthat::test_path("..", "..", "R", "bibliographic_deduplication.R"))
  expect_equal(
    normalize_bibliographic_doi(c(" DOI:10.1000/ABC ", "https://doi.org/10.2/X", NA)),
    c("10.1000/abc", "10.2/x", "")
  )
  expect_equal(
    normalize_bibliographic_title("Comparación: Health—Survey!"),
    "comparacion health survey"
  )
})

test_that("LOW screening proposals remain explicit candidates", {
  source(testthat::test_path("..", "..", "R", "bibliographic_prioritization.R"))
  proposals <- propose_low_screening(c(
    "Survey data harmonization in the social sciences",
    "Measurement invariance of the PHQ-9 across countries",
    "Remote sensing for soil monitoring",
    "A clinical study without a comparability focus"
  ))

  expect_equal(
    proposals$decision,
    c("INCLUDE", "BACKGROUND", "EXCLUDE", "EXCLUDE")
  )
  expect_equal(proposals$confidence, c("HIGH", "HIGH", "HIGH", "LOW"))
})

test_that("public project status excludes traceability-only duplicates", {
  source(testthat::test_path("..", "..", "R", "public_project_status.R"))
  pubmed <- data.frame(
    investigator_decision = c("INCLUDE", "EXCLUDE")
  )
  supplementary <- data.frame(
    investigator_decision = c("BACKGROUND", "EXCLUDE", "EXCLUDE"),
    investigator_initials = "AB",
    confirmation_date = "2026-08-23",
    investigator_notes = c("", "", "DUPLICATE; retained_record_id=X")
  )
  result <- build_public_project_status(pubmed, supplementary, 195, 154)

  expect_equal(result$literature$screened_unique, 4L)
  expect_equal(result$literature$duplicate_copies, 1L)
  expect_equal(result$literature$include, 1L)
  expect_equal(result$literature$background, 1L)
  expect_equal(result$literature$exclude, 2L)
  expect_equal(result$metadata$paris_variables, 195L)
  expect_equal(result$protocol$version, "0.3")
  expect_equal(result$protocol$active_work_package, "WP1_PROTOCOL")
})

test_that("Scopus records match PubMed by DOI before normalised title", {
  source(testthat::test_path("..", "..", "R", "bibliographic_deduplication.R"))
  pubmed <- data.frame(
    pmid = c("1", "2"), doi = c("10.1/a", NA),
    title = c("First title", "Título común")
  )
  scopus <- data.frame(
    doi = c("https://doi.org/10.1/A", NA, NA),
    title = c("Different title", "Titulo comun!", "Unique title")
  )
  result <- match_scopus_to_pubmed(scopus, pubmed)
  expect_equal(result$matched_pubmed, c(TRUE, TRUE, FALSE))
  expect_equal(result$match_basis, c("DOI", "TITLE", "NONE"))
  expect_equal(result$matched_pubmed_pmid, c("1", "2", NA_character_))
})

test_that("RIS records are parsed with repeated fields and provenance", {
  source(testthat::test_path("..", "..", "R", "ris_import.R"))
  ris <- tempfile(fileext = ".ris")
  writeLines(c(
    "TY  - JOUR", "U2  - L123", "C5  - 456", "DO  - 10.1/ABC",
    "A1  - One, A.", "A1  - Two, B.", "T1  - Example title",
    "AB  - First line", "continued abstract", "ER  -"
  ), ris, useBytes = TRUE)
  result <- parse_ris_file(ris, "NR-EMBASE-TEST")
  expect_equal(nrow(result), 1)
  expect_equal(result$embase_id, "L123")
  expect_equal(result$source_record_id, "L123")
  expect_equal(result$authors, "One, A.; Two, B.")
  expect_equal(result$abstract, "First line continued abstract")
  expect_equal(result$strategy_id, "NR-EMBASE-TEST")
})

test_that("RIS parser preserves a Web of Science accession number", {
  source(testthat::test_path("..", "..", "R", "ris_import.R"))
  ris <- tempfile(fileext = ".ris")
  writeLines(c(
    "TY  - JOUR", "UT  - WOS:000123456700001", "T1  - Example title",
    "ER  -"
  ), ris, useBytes = TRUE)
  result <- parse_ris_file(ris, "SR-WOS-A")
  expect_equal(result$source_record_id, "WOS:000123456700001")
})

test_that("bibliographic prioritisation is transparent and does not decide", {
  source(testthat::test_path("..", "..", "R", "bibliographic_prioritization.R"))
  scores <- score_bibliographic_priority(
    c(
      "Retrospective data harmonization framework for health surveys",
      "A cell atlas from genomic data"
    ),
    c("Target variables and validation guidelines", "Chemical mixture analysis")
  )
  expect_true(scores[[1]] >= 12)
  expect_true(scores[[2]] < scores[[1]])
  expect_equal(
    classify_bibliographic_priority(scores[[1]], has_core_title_signal(
      "Retrospective data harmonization framework for health surveys"
    )),
    "HIGH"
  )
  expect_equal(classify_bibliographic_priority(12, FALSE), "MEDIUM")
  expect_match(
    describe_priority_signals("Measurement invariance in a population survey"),
    "measurement_equivalence"
  )
  expect_false(grepl(
    "paris",
    describe_priority_signals("Comparison of extraction methods"),
    fixed = TRUE
  ))
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
  expect_true(all(
    reviewed$decision_status == "PENDING_INVESTIGATOR_CONFIRMATION"
  ))

  screening <- readr::read_csv(
    file.path(review_dir, "screening.csv"), show_col_types = FALSE
  )
  expect_equal(nrow(screening), 121)
  expect_setequal(screening$record_id, reviewed$record_id)
  expect_true(all(c(
    "proposed_decision", "investigator_decision", "investigator_initials",
    "confirmation_date", "investigator_notes"
  ) %in% names(screening)))
})

test_that("included evidence is tiered and core sources are extracted", {
  review_dir <- testthat::test_path("..", "..", "research", "narrative-review")
  evidence_map <- readr::read_csv(
    file.path(review_dir, "evidence-map.csv"), show_col_types = FALSE
  )
  extraction <- readr::read_csv(
    file.path(review_dir, "evidence-extraction.csv"), show_col_types = FALSE
  )
  expect_equal(nrow(evidence_map), length(unique(evidence_map$record_id)))
  expect_true(all(evidence_map$evidence_tier %in% c("CORE", "APPLIED", "SPECIALISED")))
  expect_equal(sum(evidence_map$evidence_tier == "APPLIED"), 10)
  expect_equal(sum(evidence_map$evidence_tier == "SPECIALISED"), 10)
  expect_equal(nrow(extraction), sum(evidence_map$evidence_tier == "CORE"))
  expect_setequal(extraction$record_id, evidence_map$record_id[evidence_map$evidence_tier == "CORE"])
  expect_true("DOI-10.1787-acf46da9-en" %in% extraction$record_id)
})

test_that("screening review app is self-contained and current", {
  review_dir <- testthat::test_path("..", "..", "research", "narrative-review")
  screening <- readr::read_csv(
    file.path(review_dir, "screening.csv"), show_col_types = FALSE
  )
  html <- paste(
    readLines(file.path(review_dir, "screening-review.html"), warn = FALSE),
    collapse = "\n"
  )
  expect_false(grepl("__SCREENING_DATA__", html, fixed = TRUE))
  expect_true(grepl("screening-confirmed.csv", html, fixed = TRUE))
  expect_true(all(vapply(
    screening$record_id,
    function(id) grepl(id, html, fixed = TRUE),
    logical(1)
  )))
})

test_that("public site keeps custom pages and renders only protocol with Quarto", {
  root <- testthat::test_path("..", "..")
  website_dir <- file.path(root, "website")
  config <- paste(
    readLines(file.path(website_dir, "_quarto.yml"), warn = FALSE),
    collapse = "\n"
  )
  references <- paste(
    readLines(file.path(website_dir, "referencias.html"), warn = FALSE),
    collapse = "\n"
  )
  landing <- paste(
    readLines(file.path(website_dir, "index.html"), warn = FALSE),
    collapse = "\n"
  )
  protocol_lines <- readLines(
    file.path(website_dir, "protocolo.qmd"), warn = FALSE
  )
  protocol <- paste(protocol_lines, collapse = "\n")
  public_references <- paste(
    readLines(file.path(website_dir, "data", "references.json"), warn = FALSE),
    collapse = "\n"
  )
  worker <- paste(
    readLines(file.path(root, "cloudflare", "worker.js"), warn = FALSE),
    collapse = "\n"
  )
  reference_script <- paste(
    readLines(file.path(website_dir, "references.js"), warn = FALSE),
    collapse = "\n"
  )
  programme <- paste(
    readLines(file.path(website_dir, "programa.html"), warn = FALSE),
    collapse = "\n"
  )
  programme_script <- paste(
    readLines(file.path(website_dir, "programme.js"), warn = FALSE),
    collapse = "\n"
  )
  work_packages <- jsonlite::fromJSON(
    file.path(website_dir, "data", "work-packages.json"),
    simplifyVector = FALSE
  )

  expect_false(grepl("index.qmd", config, fixed = TRUE))
  expect_false(grepl("referencias.qmd", config, fixed = TRUE))
  expect_match(config, "protocolo.qmd", fixed = TRUE)
  expect_match(config, "protocol.css", fixed = TRUE)
  expect_match(landing, "class=\"hero programme-hero\"", fixed = TRUE)
  expect_match(landing, "class=\"principle-card sober\"", fixed = TRUE)
  expect_match(landing, "Target DataSchema", fixed = TRUE)
  expect_match(programme, "data-wp-list", fixed = TRUE)
  expect_match(programme_script, "role=\"tablist\"", fixed = TRUE)
  expect_match(programme_script, "aria-selected", fixed = TRUE)
  expect_match(programme_script, "ArrowRight", fixed = TRUE)
  expect_match(programme_script, "history.replaceState", fixed = TRUE)
  expect_equal(vapply(work_packages, `[[`, character(1), "id"), paste0("WP", 0:7))
  expect_match(references, "href=\"programa.html#wp1\"", fixed = TRUE)
  expect_match(references, "WP1", fixed = TRUE)
  expect_match(references, "source-filter", fixed = TRUE)
  expect_match(references, "decision-filter", fixed = TRUE)
  expect_match(references, "<th>IA sistem", fixed = TRUE)
  expect_match(references, "<th>JALR</th>", fixed = TRUE)
  expect_match(references, "<th>Investigador 2</th>", fixed = TRUE)
  expect_match(references, "reference-pagination", fixed = TRUE)
  expect_match(references, "href=\"/api/login\"", fixed = TRUE)
  expect_match(references, "review-filter", fixed = TRUE)
  expect_match(references, "review-feedback", fixed = TRUE)
  # ASCII stems keep these structural checks portable across Windows R locales.
  expect_true(any(grepl("^# Introducci", protocol_lines)))
  expect_true(any(grepl("^# M.*todos$", protocol_lines)))
  expect_true(any(grepl("^# Discusi", protocol_lines)))
  expect_false(any(grepl("^# Resultados$", protocol_lines)))
  expect_match(protocol, "hypothesis:", fixed = TRUE)
  expect_match(protocol, "generated/search-strategies.md", fixed = TRUE)
  expect_false(grepl("investigator_decision", public_references, fixed = TRUE))
  expect_false(grepl("jalr_decision", public_references, fixed = TRUE))
  expect_false(grepl("abstract_text", public_references, fixed = TRUE))
  expect_match(reference_script, "current_review", fixed = TRUE)
  expect_match(reference_script, "/api/decisions", fixed = TRUE)
  expect_match(reference_script, "/api/references/${", fixed = TRUE)
  expect_match(worker, "bothReviewed", fixed = TRUE)
  expect_match(worker, "revealCompletedReview", fixed = TRUE)
  expect_match(worker, "current_review", fixed = TRUE)
  expect_match(worker, "sameOrigin", fixed = TRUE)
  expect_match(worker, "REASON_CODES", fixed = TRUE)
  expect_match(worker, "abstract_text", fixed = TRUE)
  expect_match(worker, "AI_MODEL_RUN_ID", fixed = TRUE)
})
