source("scripts/00_setup.R")

quarto <- Sys.which("quarto")
if (!nzchar(quarto)) {
  stop("Quarto is not available on PATH.", call. = FALSE)
}

output_dir <- file.path(project_root, "website", "_site")
if (dir.exists(output_dir)) {
  normalized_output <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  normalized_website <- normalizePath(
    file.path(project_root, "website"), winslash = "/", mustWork = TRUE
  )
  if (dirname(normalized_output) != normalized_website || basename(normalized_output) != "_site") {
    stop("Refusing to clean an unexpected Quarto output directory.", call. = FALSE)
  }
  unlink(normalized_output, recursive = TRUE, force = TRUE)
}

status <- system2(quarto, c("render", "website"))
if (!identical(status, 0L)) {
  stop("Quarto website render failed.", call. = FALSE)
}

message(
  "Quarto website rendered to: ",
  output_dir
)
