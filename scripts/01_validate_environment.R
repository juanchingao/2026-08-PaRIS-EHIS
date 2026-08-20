source("scripts/00_setup.R")

checks <- data.frame(
  check = c("R >= 4.4", "project root", "raw directory", "metadata directory",
            "derived directory", "outputs directory"),
  ok = c(getRversion() >= "4.4.0", dir.exists(project_paths$root),
         dir.exists(project_paths$raw), dir.exists(project_paths$metadata),
         dir.exists(project_paths$derived), dir.exists(project_paths$outputs)),
  detail = c(as.character(getRversion()), project_paths$root, project_paths$raw,
             project_paths$metadata, project_paths$derived, project_paths$outputs)
)

print(checks, row.names = FALSE)
if (!all(checks$ok)) stop("Environment validation failed.", call. = FALSE)
message("All environment checks passed.")
