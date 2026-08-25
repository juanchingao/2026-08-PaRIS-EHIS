source("scripts/00_setup.R")

required <- c("dplyr", "readr", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

manifest_path <- file.path(
  project_root, "research", "scoping-review", "manifests", "manual-exports.csv"
)
manifest <- readr::read_csv(manifest_path, show_col_types = FALSE)
ready <- manifest |> dplyr::filter(status == "READY")
if (!nrow(ready)) {
  message("No manual exports are marked READY; nothing imported.")
  quit(save = "no", status = 0L)
}
strategies <- load_scoping_search_strategies(project_root)
paths <- scoping_search_paths(project_paths)
for (index in seq_len(nrow(ready))) {
  item <- ready[index, ]
  strategy <- strategies |>
    dplyr::filter(search_strategy_id == item$search_strategy_id)
  if (nrow(strategy) != 1L) stop("Unknown strategy in manual manifest.", call. = FALSE)
  source_path <- file.path(project_root, item$relative_path)
  if (!file.exists(source_path)) stop("Missing manual export: ", item$relative_path, call. = FALSE)
  records <- import_manual_bibliographic_file(source_path, strategy, item$database)
  records$raw_file <- item$relative_path
  output_path <- file.path(paths$interim, paste0(tolower(item$import_id), "-records.csv"))
  readr::write_csv(records, output_path, na = "")
  message("Imported ", nrow(records), " records from ", item$import_id, ".")
}
