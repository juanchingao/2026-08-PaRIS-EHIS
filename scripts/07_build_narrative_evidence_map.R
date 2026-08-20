source("scripts/00_setup.R")

required <- c("dplyr", "readr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
reviewed <- readr::read_csv(
  file.path(review_dir, "reviewed-screening.csv"), show_col_types = FALSE
) |>
  dplyr::filter(decision == "INCLUDE")

core <- c(
  "42207414", "27272186", "24257327", "35957574", "33184054",
  "40791144", "31018973", "38365871", "38953657", "38354027",
  "37464990", "34689753", "29511034", "39174334", "40998583"
)
applied <- c(
  "37332385", "35618987", "35252528", "33413280", "27215626",
  "35411334", "33352669", "30478617", "38156337", "27621257"
)
specialised <- c(
  "26524232", "38531091", "33152178", "33610807", "30235003",
  "24262771", "38577153", "30578242", "24767588", "39511613"
)
stopifnot(setequal(reviewed$pmid, c(core, applied, specialised)))

framework <- c(
  "27272186", "24257327", "35957574", "33184054", "40791144",
  "31018973", "38365871", "37464990", "30578242", "27621257"
)
metadata <- c("38354027")
potential <- c("38953657", "34689753", "35252528", "35411334", "38577153")
paris <- c("39174334", "40998583", "38156337")
ehis <- c("37332385", "35618987", "27215626", "33352669", "30478617")
psychometric <- c(
  "42207414", "26524232", "38531091", "33152178", "33610807",
  "30235003", "24262771", "24767588", "39511613", "29511034",
  "33413280"
)

evidence_map <- reviewed |>
  dplyr::mutate(
    evidence_tier = dplyr::case_when(
      pmid %in% core ~ "CORE",
      pmid %in% applied ~ "APPLIED",
      pmid %in% specialised ~ "SPECIALISED"
    ),
    primary_theme = dplyr::case_when(
      pmid %in% paris ~ "PaRIS primary methods",
      pmid %in% ehis ~ "EHIS comparability evidence",
      pmid %in% metadata ~ "Metadata and provenance",
      pmid %in% potential ~ "Pre-statistical harmonisation potential",
      pmid %in% framework ~ "Harmonisation framework and implementation",
      pmid %in% psychometric ~ "Measurement equivalence and statistical linking",
      TRUE ~ "Other transferable methods"
    ),
    project_use = dplyr::case_when(
      evidence_tier == "CORE" ~ "Directly informs protocol and data model",
      evidence_tier == "APPLIED" ~ "Supports operational criteria and sensitivity analyses",
      TRUE ~ "Use conditionally for complex scales or specific domains"
    ),
    full_text_priority = dplyr::case_when(
      evidence_tier == "CORE" ~ "HIGH",
      evidence_tier == "APPLIED" ~ "MEDIUM",
      TRUE ~ "CONDITIONAL"
    )
  ) |>
  dplyr::arrange(
    factor(evidence_tier, levels = c("CORE", "APPLIED", "SPECIALISED")),
    primary_theme, dplyr::desc(year)
  ) |>
  dplyr::select(
    record_id, pmid, doi, title, authors, year, journal, pubmed_url,
    evidence_tier, primary_theme, project_use, full_text_priority
  )

readr::write_csv(evidence_map, file.path(review_dir, "evidence-map.csv"), na = "")

core_extraction <- evidence_map |>
  dplyr::filter(evidence_tier == "CORE") |>
  dplyr::transmute(
    record_id,
    citation = paste0(authors, " (", year, "). ", title),
    document_type = primary_theme,
    studies_or_surveys = dplyr::case_when(
      pmid %in% c("39174334", "40998583") ~ "PaRIS",
      TRUE ~ "Multiple cohorts, surveys, or methodological literature"
    ),
    population = dplyr::case_when(
      pmid %in% c("39174334", "40998583") ~ "People aged 45+ using primary care; international development samples",
      TRUE ~ "Study-specific populations; methodological focus"
    ),
    variable_types = dplyr::case_when(
      pmid == "42207414" ~ "Observed variables and latent constructs",
      pmid %in% c("34689753", "38953657") ~ "Questionnaire items and scales",
      TRUE ~ "Mixed epidemiological variables"
    ),
    conceptual_model = dplyr::case_when(
      pmid == "27272186" ~ "Maelstrom stepwise retrospective harmonisation",
      pmid %in% c("24257327", "33184054") ~ "Target-variable/DataSchema model",
      pmid == "39174334" ~ "PaRIS conceptual framework",
      pmid == "29511034" ~ "Measurement non-equivalence vocabulary",
      TRUE ~ "Study-specific or reviewed framework"
    ),
    target_definition = dplyr::case_when(
      pmid %in% c("27272186", "24257327", "33184054") ~ "Defined before study-specific algorithms",
      pmid %in% c("34689753", "38953657") ~ "Common construct/item representation after pre-statistical review",
      TRUE ~ "Relevant but not always formalised as a target variable"
    ),
    compatibility_dimensions = dplyr::case_when(
      pmid == "29511034" ~ "Construct, item, response process, population and context",
      pmid %in% c("34689753", "38953657") ~ "Content, wording, scoring, administration and item quality",
      TRUE ~ "Concept, population, measurement, format and study procedures"
    ),
    harmonisation_method = dplyr::case_when(
      pmid == "42207414" ~ "Distribution-based, proportion-score and latent-variable methods",
      pmid == "34689753" ~ "Pre-statistical item review followed by IRT co-calibration",
      pmid %in% c("24257327", "33184054") ~ "Study-specific processing algorithms to a common target",
      TRUE ~ "Conceptual mapping and documented transformation"
    ),
    missing_data = "Retain structural absence and study-specific missingness; assess by target and method",
    validation = dplyr::case_when(
      pmid %in% c("34689753", "38953657") ~ "Item quality/model fit plus expert content review",
      pmid %in% c("27272186", "24257327", "33184054") ~ "Harmonisation potential and output quality assessment",
      TRUE ~ "Method- or study-specific validation"
    ),
    sensitivity = "Compare plausible mappings, populations, transformations, or statistical assumptions",
    software_or_infrastructure = dplyr::case_when(
      pmid %in% c("24257327", "33184054", "40791144") ~ "Federated or metadata-driven research infrastructure",
      TRUE ~ "Not prescriptive for this project"
    ),
    provenance = "Version mappings, algorithms, sources, decisions and generated outputs",
    limitations = dplyr::case_when(
      pmid == "42207414" ~ "Statistical methods depend strongly on scale and target type",
      pmid %in% c("34689753", "38953657") ~ "Statistical linking requires defensible anchors and assumptions",
      TRUE ~ "Transferability depends on survey purpose, population and available metadata"
    ),
    paris_ehis_implication = project_use,
    disposition = "ADOPT_OR_ADAPT",
    reviewer = "Codex; investigator confirmation required",
    review_date = as.character(Sys.Date())
  )

readr::write_csv(
  core_extraction, file.path(review_dir, "evidence-extraction.csv"), na = ""
)
message("Mapped 35 included records and extracted 15 core sources.")
