source("scripts/00_setup.R")
source("R/bibliographic_prioritization.R")

required <- c("dplyr", "readr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
export_dir <- file.path(review_dir, "exports")

scopus <- readr::read_csv(
  file.path(export_dir, "scopus-not-in-pubmed.csv"), show_col_types = FALSE
) |>
  dplyr::transmute(
    record_id = paste0("SCOPUS-", scopus_id),
    source_database = "Scopus",
    source_id = scopus_id,
    strategy_id,
    pmid = "",
    doi = dplyr::coalesce(doi, ""),
    title,
    abstract = "",
    keywords = "",
    authors = dplyr::coalesce(authors, ""),
    journal = dplyr::coalesce(publication, ""),
    year,
    citations = dplyr::coalesce(as.integer(citations), 0L),
    source_url = paste0(
      "https://www.scopus.com/record/display.uri?eid=", scopus_id,
      "&origin=resultslist"
    )
  )

embase <- readr::read_csv(
  file.path(export_dir, "embase-not-in-pubmed-scopus.csv"), show_col_types = FALSE
) |>
  dplyr::transmute(
    record_id = paste0("EMBASE-", embase_id),
    source_database = "Embase",
    source_id = embase_id,
    strategy_id,
    pmid = dplyr::coalesce(as.character(pmid), ""),
    doi = dplyr::coalesce(doi, ""),
    title,
    abstract = dplyr::coalesce(abstract, ""),
    keywords = dplyr::coalesce(keywords, ""),
    authors = dplyr::coalesce(authors, ""),
    journal = dplyr::coalesce(journal, ""),
    year,
    citations = 0L,
    source_url = dplyr::coalesce(embase_url, "")
  )

candidates <- dplyr::bind_rows(scopus, embase) |>
  dplyr::mutate(
    base_score = score_bibliographic_priority(title, abstract, keywords),
    strategy_overlap_bonus = as.integer(grepl(";", strategy_id, fixed = TRUE)),
    priority_score = base_score + strategy_overlap_bonus,
    core_title_signal = has_core_title_signal(title),
    priority_tier = classify_bibliographic_priority(
      priority_score, core_title_signal
    ),
    priority_signals = describe_priority_signals(title, abstract, keywords),
    abstract_available = nzchar(abstract),
    stage = dplyr::if_else(abstract_available, "title_abstract", "title_only"),
    proposed_decision = paste0("PRIORITY_", priority_tier),
    proposed_reason = paste0(
      "Transparent prioritisation only; score=", priority_score,
      "; signals=", priority_signals,
      dplyr::if_else(abstract_available, "", "; title-only record")
    ),
    proposed_reviewer = "Deterministic ranking; no inclusion decision",
    proposed_review_date = as.character(Sys.Date())
  ) |>
  dplyr::arrange(
    factor(priority_tier, levels = c("HIGH", "MEDIUM", "LOW")),
    dplyr::desc(priority_score), dplyr::desc(citations), dplyr::desc(year), title
  )

low_proposals <- propose_low_screening(
  candidates$title, candidates$abstract, candidates$keywords
)
candidates <- candidates |>
  dplyr::mutate(
    low_proposed_decision = dplyr::if_else(
      priority_tier == "LOW", low_proposals$decision, NA_character_
    ),
    low_proposal_confidence = dplyr::if_else(
      priority_tier == "LOW", low_proposals$confidence, NA_character_
    ),
    low_proposal_reason = dplyr::if_else(
      priority_tier == "LOW", low_proposals$reason, NA_character_
    ),
    proposed_decision = dplyr::if_else(
      priority_tier == "LOW", low_proposed_decision, proposed_decision
    ),
    proposed_reason = dplyr::if_else(
      priority_tier == "LOW",
      paste0(
        "Automated LOW-tier proposal; confidence=", low_proposal_confidence,
        "; ", low_proposal_reason,
        "; priority_score=", priority_score,
        "; signals=", priority_signals,
        dplyr::if_else(abstract_available, "", "; title-only record")
      ),
      proposed_reason
    ),
    proposed_reviewer = dplyr::if_else(
      priority_tier == "LOW",
      "Deterministic proposal; requires investigator confirmation",
      proposed_reviewer
    )
  )

if (nrow(candidates) != 970L || anyDuplicated(candidates$record_id)) {
  stop("Supplementary candidate count or identifiers are inconsistent.", call. = FALSE)
}

readr::write_csv(
  candidates,
  file.path(export_dir, "supplementary-ranked-candidates.csv"), na = ""
)

screening_path <- file.path(review_dir, "supplementary-screening.csv")
previous <- if (file.exists(screening_path)) {
  readr::read_csv(screening_path, show_col_types = FALSE)
} else {
  tibble::tibble()
}

screening <- candidates |>
  dplyr::select(
    record_id, source_database, source_id, pmid, doi, title, stage,
    priority_tier, priority_score, priority_signals,
    low_proposed_decision, low_proposal_confidence, low_proposal_reason,
    proposed_decision, proposed_reason, proposed_reviewer, proposed_review_date
  )

confirmation_fields <- c(
  "record_id", "investigator_decision", "investigator_initials",
  "confirmation_date", "investigator_notes"
)
if (all(confirmation_fields %in% names(previous))) {
  screening <- screening |>
    dplyr::left_join(
      previous |> dplyr::select(dplyr::all_of(confirmation_fields)),
      by = "record_id"
    )
} else {
  screening <- screening |>
    dplyr::mutate(
      investigator_decision = NA_character_,
      investigator_initials = NA_character_,
      confirmation_date = NA_character_,
      investigator_notes = NA_character_
    )
}
screening <- screening |>
  dplyr::mutate(
    investigator_initials = dplyr::if_else(
      !is.na(investigator_decision) & nzchar(investigator_decision) &
        (is.na(investigator_initials) | !nzchar(investigator_initials)),
      "JALR",
      investigator_initials
    )
  )
readr::write_csv(screening, screening_path, na = "")

summary <- candidates |>
  dplyr::count(source_database, priority_tier, abstract_available, name = "records") |>
  dplyr::arrange(
    source_database,
    factor(priority_tier, levels = c("HIGH", "MEDIUM", "LOW")),
    dplyr::desc(abstract_available)
  )
readr::write_csv(
  summary, file.path(review_dir, "supplementary-priority-summary.csv"), na = ""
)
print(summary)
message("Prioritised 970 supplementary candidates; no inclusion decisions assigned.")
