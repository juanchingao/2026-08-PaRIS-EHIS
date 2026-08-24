score_bibliographic_priority <- function(title, abstract = "", keywords = "") {
  text <- paste(
    ifelse(is.na(title), "", title),
    ifelse(is.na(abstract), "", abstract),
    ifelse(is.na(keywords), "", keywords)
  )
  hit <- function(pattern, points) {
    as.integer(grepl(pattern, text, ignore.case = TRUE, perl = TRUE)) * points
  }
  hit("retrospective (data )?harmoni[sz]", 8L) +
    hit("data harmoni[sz]", 4L) +
    hit("target(ed)? variable|common data model|dataschema", 4L) +
    hit("measurement equivalence|measurement invariance", 4L) +
    hit("scale linking|item response theory|common metric", 3L) +
    hit("survey|cohort|epidemiolog", 2L) +
    hit("patient.?reported|\bPROMs?\b|\bPREMs?\b", 2L) +
    hit("\\bPaRIS\\b|Patient.?Reported Indicator Survey", 6L) +
    hit("European Health Interview Survey|\bEHIS\b", 6L) +
    hit("guideline|framework|method|validation", 2L) +
    hit("systematic review|scoping review|meta-analysis", 2L) -
    hit(
      "genom|proteom|metabolom|cell atlas|diffusion MRI|chemical mixture|soil|crop|agricultur|remote sensing",
      4L
    )
}

has_core_title_signal <- function(title) {
  title <- ifelse(is.na(title), "", title)
  grepl(
    paste0(
      "retrospective (data )?harmoni[sz]|data harmoni[sz]|",
      "measurement equivalence|measurement invariance|questionnaire harmoni[sz]|",
      "scale linking|common metric|\\bPaRIS\\b|Patient.?Reported Indicator Survey|",
      "European Health Interview Survey|\\bEHIS\\b"
    ),
    title, ignore.case = TRUE, perl = TRUE
  )
}

classify_bibliographic_priority <- function(score, core_title_signal = FALSE) {
  high <- score >= 16L | (core_title_signal & score >= 10L)
  ifelse(high, "HIGH", ifelse(score >= 7L, "MEDIUM", "LOW"))
}

describe_priority_signals <- function(title, abstract = "", keywords = "") {
  text <- paste(
    ifelse(is.na(title), "", title),
    ifelse(is.na(abstract), "", abstract),
    ifelse(is.na(keywords), "", keywords)
  )
  patterns <- c(
    retrospective_harmonisation = "retrospective (data )?harmoni[sz]",
    data_harmonisation = "data harmoni[sz]",
    target_model = "target(ed)? variable|common data model|dataschema",
    measurement_equivalence = "measurement equivalence|measurement invariance",
    scale_linking = "scale linking|item response theory|common metric",
    survey_population = "survey|cohort|epidemiolog",
    patient_reported = "patient.?reported|\\bPROMs?\\b|\\bPREMs?\\b",
    paris = "\\bPaRIS\\b|Patient.?Reported Indicator Survey",
    ehis = "European Health Interview Survey|\\bEHIS\\b",
    methods = "guideline|framework|method|validation",
    evidence_synthesis = "systematic review|scoping review|meta-analysis",
    out_of_scope_penalty = paste0(
      "genom|proteom|metabolom|cell atlas|diffusion MRI|chemical mixture|",
      "soil|crop|agricultur|remote sensing"
    )
  )
  vapply(seq_along(text), function(i) {
    hits <- names(patterns)[vapply(
      patterns, grepl, logical(1), x = text[[i]], ignore.case = TRUE, perl = TRUE
    )]
    if (length(hits)) paste(hits, collapse = ";") else "none"
  }, character(1))
}

propose_low_screening <- function(title, abstract = "", keywords = "") {
  title_text <- ifelse(is.na(title), "", title)
  full_text <- paste(
    title_text,
    ifelse(is.na(abstract), "", abstract),
    ifelse(is.na(keywords), "", keywords)
  )
  matches <- function(pattern, text = full_text) {
    grepl(pattern, text, ignore.case = TRUE, perl = TRUE)
  }

  explicit_survey <- matches(
    "\\bPaRIS\\b|Patient.?Reported Indicator Survey|European Health Interview Survey|\\bEHIS\\b",
    title_text
  )
  harmonisation_method <- matches(
    paste0(
      "retrospective (data )?harmoni[sz]|survey data harmoni[sz]|",
      "data harmoni[sz].*(survey|cohort)|harmoni[sz].*(survey|cohort|questionnaire)"
    ),
    title_text
  )
  measurement_method <- matches(
    "measurement equivalence|measurement invariance|scale linking|common metric|item response theory",
    title_text
  )
  clearly_out_of_scope <- matches(
    paste0(
      "genom|proteom|metabolom|cell atlas|diffusion MRI|chemical mixture|",
      "soil|crop|agricultur|remote sensing|wildlife|pathogen detection|",
      "functional connectivity|brain imaging|neuroimaging|Alzheimer|",
      "disease-modifying treatment|arsenic exposure|single nucle"
    )
  )

  decision <- ifelse(
    explicit_survey, "INCLUDE",
    ifelse(
      clearly_out_of_scope, "EXCLUDE",
      ifelse(
        harmonisation_method, "INCLUDE",
        ifelse(measurement_method, "BACKGROUND", "EXCLUDE")
      )
    )
  )
  confidence <- ifelse(
    explicit_survey | harmonisation_method | measurement_method |
      clearly_out_of_scope,
    "HIGH", "LOW"
  )
  reason <- ifelse(
    explicit_survey,
    "Explicit PaRIS or EHIS focus in title",
    ifelse(
      clearly_out_of_scope,
      "Clearly outside health-survey conceptual harmonisation scope",
      ifelse(
        harmonisation_method,
        "Explicit survey/cohort data harmonisation focus in title",
        ifelse(
          measurement_method,
          "Measurement equivalence, invariance or linking method relevant as background",
          "No explicit PaRIS, EHIS, survey-harmonisation or measurement-comparability signal; title/abstract review still required"
        )
      )
    )
  )

  data.frame(
    decision = decision,
    confidence = confidence,
    reason = reason,
    stringsAsFactors = FALSE
  )
}
