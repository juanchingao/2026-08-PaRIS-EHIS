project_env_path <- function(name, fallback) {
  value <- Sys.getenv(name, unset = "")
  if (nzchar(value)) normalizePath(value, winslash = "/", mustWork = FALSE) else fallback
}

get_project_paths <- function(root = getwd()) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  list(
    root = root,
    raw = project_env_path("PARISEHIS_RAW_DIR", file.path(root, "data", "raw")),
    derived = project_env_path("PARISEHIS_DERIVED_DIR", file.path(root, "data", "processed")),
    interim = project_env_path("PARISEHIS_INTERIM_DIR", file.path(root, "data", "interim")),
    metadata = file.path(root, "data", "metadata"),
    outputs = project_env_path("PARISEHIS_OUTPUTS_DIR", file.path(root, "outputs")),
    logs = project_env_path("PARISEHIS_LOGS_DIR", file.path(root, "logs"))
  )
}
