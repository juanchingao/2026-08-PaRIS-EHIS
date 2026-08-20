source("scripts/00_setup.R")

required <- c("dplyr", "readr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

review_dir <- file.path(project_root, "research", "narrative-review")
candidates <- readr::read_csv(
  file.path(review_dir, "exports", "ranked-candidates.csv"), show_col_types = FALSE
)

include_pmids <- c(
  "37332385", "42207414", "27272186", "24257327", "35957574",
  "35618987", "35252528", "33184054", "26524232", "40791144",
  "33413280", "31018973", "27215626", "38531091", "35411334",
  "33352669", "30478617", "33152178", "33610807", "30235003",
  "24262771", "39174334", "40998583", "38365871", "38577153",
  "38953657", "38156337", "38354027", "37464990", "30578242",
  "27621257", "24767588", "39511613", "34689753", "29511034"
)

background_pmids <- c(
  "35449545", "37378690", "30382716", "33836996", "42221536",
  "37667811", "39042420", "36637894", "35081452", "36011429",
  "30530137", "25627670", "17060838", "41923015", "40573146",
  "39281853", "38755748", "37469576", "34498557", "37535410",
  "34327634", "33546272", "30321436", "29315123", "29495212",
  "25006191", "41168823", "34089412", "22552604"
)

stopifnot(!length(intersect(include_pmids, background_pmids)))
stopifnot(all(c(include_pmids, background_pmids) %in% candidates$pmid))

reviewed <- candidates |>
  dplyr::mutate(
    decision = dplyr::case_when(
      pmid %in% include_pmids ~ "INCLUDE",
      pmid %in% background_pmids ~ "BACKGROUND",
      TRUE ~ "EXCLUDE"
    ),
    reason = dplyr::case_when(
      decision == "INCLUDE" ~ paste(
        "Direct methodological contribution, survey-comparability evidence,",
        "or primary PaRIS/EHIS methods relevant to the framework"
      ),
      decision == "BACKGROUND" ~ paste(
        "Adjacent methodological or psychometric evidence useful for context,",
        "but not central to PaRIS-EHIS harmonisation"
      ),
      TRUE ~ paste(
        "Substantive application, population-specific instrument validation,",
        "or technical topic without transferable harmonisation guidance"
      )
    ),
    reviewer = "Codex; title/abstract review for investigator confirmation",
    review_date = as.character(Sys.Date()),
    notes = paste0(
      "Title and abstract reviewed. Initial relevance score: ", relevance_score
    )
  ) |>
  dplyr::select(
    record_id, pmid, doi, title, abstract, authors, journal, year,
    publication_types, pubmed_url, strategy_id, relevance_score,
    stage, decision, reason, reviewer, review_date, notes
  )

readr::write_csv(
  reviewed, file.path(review_dir, "reviewed-screening.csv"), na = ""
)
summary <- reviewed |>
  dplyr::count(decision, name = "records") |>
  dplyr::arrange(factor(decision, levels = c("INCLUDE", "BACKGROUND", "EXCLUDE")))
readr::write_csv(
  summary, file.path(review_dir, "screening-summary.csv"), na = ""
)
message(
  paste(paste0(summary$decision, "=", summary$records), collapse = "; "),
  ". Decisions require investigator confirmation."
)
