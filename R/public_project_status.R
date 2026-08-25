build_public_project_status <- function(
    pubmed_screening,
    supplementary_screening,
    paris_variables,
    ehis_variables,
    duplicate_pattern = "^DUPLICATE;") {
  required_screening <- c(
    "investigator_decision", "investigator_initials", "confirmation_date",
    "investigator_notes"
  )
  if (!all(required_screening %in% names(supplementary_screening))) {
    stop("Supplementary screening is missing required decision fields.", call. = FALSE)
  }

  duplicate_copy <- grepl(
    duplicate_pattern,
    ifelse(is.na(supplementary_screening$investigator_notes), "",
           supplementary_screening$investigator_notes)
  )
  supplementary_unique <- supplementary_screening[!duplicate_copy, , drop = FALSE]
  decisions <- c(
    as.character(pubmed_screening$investigator_decision),
    as.character(supplementary_unique$investigator_decision)
  )
  decision_counts <- table(factor(
    decisions,
    levels = c("INCLUDE", "BACKGROUND", "EXCLUDE")
  ))

  list(
    updated = as.character(Sys.Date()),
    protocol = list(
      version = "0.3",
      status = "PROPOSED",
      index_survey = "PaRIS Cycle 1",
      first_comparator = "EHIS Wave 3",
      active_work_package = "WP1_PROTOCOL"
    ),
    literature = list(
      retrieved_unique = 1783L,
      screened_unique = length(decisions),
      include = unname(as.integer(decision_counts[["INCLUDE"]])),
      background = unname(as.integer(decision_counts[["BACKGROUND"]])),
      exclude = unname(as.integer(decision_counts[["EXCLUDE"]])),
      supplementary_rows = nrow(supplementary_screening),
      supplementary_unique = nrow(supplementary_unique),
      duplicate_copies = sum(duplicate_copy)
    ),
    metadata = list(
      paris_variables = as.integer(paris_variables),
      ehis_variables = as.integer(ehis_variables)
    ),
    safeguards = list(
      microdata_published = FALSE,
      licensed_abstracts_published = FALSE,
      automated_equivalence = FALSE
    )
  )
}
