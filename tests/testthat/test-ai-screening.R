test_that("AI screening inputs exclude human decisions and preserve evidence stage", {
  source(testthat::test_path("..", "..", "R", "ai_screening.R"))
  records <- data.frame(
    record_id = c("SYNTHETIC-1", "SYNTHETIC-2"),
    source_database = c("PubMed", "Scopus"),
    source_id = c("1", "2"),
    title = c("Retrospective survey harmonisation", "Unrelated title"),
    abstract_text = c("A synthetic methods abstract.", NA),
    stage = c("TITLE_ABSTRACT", "TITLE_ONLY"),
    access_class = c("PUBLIC", "RESTRICTED")
  )
  expect_invisible(validate_ai_screening_records(records))
  expect_error(
    validate_ai_screening_records(transform(records, investigator_decision = "INCLUDE")),
    "Human or prior-assessment"
  )

  schema <- jsonlite::read_json(
    testthat::test_path(
      "..", "..", "research", "narrative-review", "ai-screening",
      "response-schema-v1.json"
    ),
    simplifyVector = FALSE
  )
  request <- build_openai_screening_request(
    records[2, ], "Synthetic prompt", schema, "synthetic-model"
  )
  expect_equal(request$custom_id, "SYNTHETIC-2")
  expect_equal(request$url, "/v1/responses")
  expect_equal(request$body$text$format$type, "json_schema")
  expect_true(request$body$text$format$strict)
  expect_match(request$body$input[[2]]$content, '"evidence_basis":"TITLE_ONLY"', fixed = TRUE)
  expect_match(request$body$input[[2]]$content, '"abstract":null', fixed = TRUE)
  expect_false(grepl("decision", request$body$input[[2]]$content, fixed = TRUE))
})

test_that("AI screening results require controlled, internally consistent values", {
  source(testthat::test_path("..", "..", "R", "ai_screening.R"))
  assessment <- list(
    decision = "BACKGROUND",
    primary_reason_code = "METHODOLOGICAL_BACKGROUND",
    evidence_basis = "TITLE_ONLY",
    certainty = "LOW",
    needs_human_review = TRUE,
    criteria = stats::setNames(
      as.list(rep("UNCLEAR", length(ai_screening_criteria))),
      ai_screening_criteria
    ),
    rationale = "El título es potencialmente pertinente, pero falta el resumen."
  )
  expect_invisible(validate_ai_screening_assessment(assessment))
  invalid <- assessment
  invalid$decision <- "EXCLUDE"
  invalid$primary_reason_code <- "INSUFFICIENT_INFORMATION"
  expect_error(validate_ai_screening_assessment(invalid), "EXCLUDE cannot")

  batch_line <- jsonlite::toJSON(list(
    custom_id = "SYNTHETIC-2",
    response = list(
      status_code = 200L,
      body = list(
        status = "completed",
        output = list(list(
          type = "message",
          content = list(list(
            type = "output_text",
            text = jsonlite::toJSON(assessment, auto_unbox = TRUE)
          ))
        ))
      )
    ),
    error = NULL
  ), auto_unbox = TRUE, null = "null")
  parsed <- parse_openai_screening_batch_line(batch_line)
  expect_equal(parsed$custom_id, "SYNTHETIC-2")
  expect_equal(parsed$assessment$decision, "BACKGROUND")
})

test_that("AI screening configuration is frozen and requires upload authorisation", {
  root <- testthat::test_path("..", "..")
  config <- yaml::read_yaml(file.path(root, "config", "ai-screening.yml"))
  prompt <- paste(readLines(file.path(root, config$prompt_path), warn = FALSE), collapse = "\n")
  schema <- jsonlite::read_json(file.path(root, config$schema_path), simplifyVector = FALSE)
  submit_script <- paste(
    readLines(file.path(root, "scripts", "20_openai_ai_screening_batch.R"), warn = FALSE),
    collapse = "\n"
  )

  expect_equal(config$method, "LLM_MULTIPROMPT_TITLE_ABSTRACT")
  expect_true(config$require_explicit_restricted_upload_authorisation)
  expect_match(prompt, "No uses decisiones humanas", fixed = TRUE)
  expect_true(schema$additionalProperties == FALSE)
  expect_match(submit_script, "AI_SCREENING_ALLOW_RESTRICTED_UPLOAD", fixed = TRUE)
  expect_match(submit_script, "OPENAI_API_KEY", fixed = TRUE)
})
