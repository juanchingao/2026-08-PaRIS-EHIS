required <- "yaml"
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing packages: ", paste(missing, collapse = ", "),
       ". Run renv::restore() first.", call. = FALSE)
}

project_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
if (!file.exists(file.path(project_root, "config", "project.yml"))) {
  stop("Run scripts from the project root.", call. = FALSE)
}

source(file.path(project_root, "config", "paths.R"))
project_paths <- get_project_paths()
project_config <- yaml::read_yaml(file.path(project_root, "config", "project.yml"))

for (path in project_paths[c("derived", "interim", "metadata", "outputs", "logs")]) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
}

r_files <- list.files(file.path(project_root, "R"), pattern = "[.]R$", full.names = TRUE)
invisible(lapply(sort(r_files), source))
options(stringsAsFactors = FALSE, scipen = 999)
message("PaRISEHIS environment ready: ", project_paths$root)
