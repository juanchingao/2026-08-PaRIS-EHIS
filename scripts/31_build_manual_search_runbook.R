source("scripts/00_setup.R")

required <- c("readr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing packages: ", paste(missing, collapse = ", "), call. = FALSE)

strategies <- load_scoping_search_strategies(project_root)
manual <- strategies[
  strategies$database %in% c(
    "Embase", "APA PsycINFO", "Web of Science Core Collection"
  ),
]

lines <- c(
  "# Ejecución manual: Embase.com, APA PsycINFO y Web of Science",
  "",
  "**Versión del documento maestro:** 0.3",
  paste0("**Generado:** ", Sys.Date()),
  "**Regla:** ejecutar A, B y C por separado, sin unirlas mediante `AND`.",
  "",
  "No aplicar filtros de fecha, idioma, humanos o tipo documental. Anotar el",
  "total mostrado antes de exportar. Si la plataforma limita el tamaño de cada",
  "exportación, crear lotes consecutivos sin solapamientos.",
  ""
)

for (database in c("Embase", "APA PsycINFO", "Web of Science Core Collection")) {
  label <- switch(
    database,
    Embase = "Embase.com",
    `APA PsycINFO` = "APA PsycINFO — EBSCOhost",
    `Web of Science Core Collection` = "Web of Science Core Collection"
  )
  lines <- c(lines, paste0("## ", label), "")
  if (database == "Embase") {
    lines <- c(
      lines,
      "La versión actual usa texto libre en `:ti,ab,kw`. Los descriptores",
      "Emtree solo se añadirán después de verificarlos en Embase.com.",
      ""
    )
  }
  if (database == "APA PsycINFO") {
    lines <- c(
      lines,
      "La consulta usa `TI`, `AB` y `KW`. Tras acceder, revisar el APA",
      "Thesaurus y añadir encabezamientos `SU` validados como complemento.",
      "No activar expansores de materias sin registrarlo como modificación.",
      ""
    )
  }
  subset <- manual[manual$database == database, ]
  for (index in seq_len(nrow(subset))) {
    item <- subset[index, ]
    lines <- c(
      lines,
      paste0("### Línea ", item$search_line, " — `", item$search_strategy_id, "`"),
      "",
      paste0("Versión de estrategia: ", item$search_version, "."),
      "",
      paste0("Campos: ", item$fields, ". Filtros: ", item$filters, "."),
      "",
      "```text",
      item$query,
      "```",
      ""
    )
  }
}

lines <- c(
  lines,
  "## Exportación y entrega",
  "",
  "1. Exportar cada línea por separado en RIS, incluyendo como mínimo título,",
  "   resumen, autores, año, revista, DOI, PMID, palabras clave, descriptores y",
  "   el identificador propio de la base. En Web of Science seleccionar Core",
  "   Collection y `Full Record and Cited References` cuando esté disponible.",
  "   En EBSCOhost verificar que la base seleccionada sea solo APA PsycINFO.",
  "2. Usar los nombres y rutas predefinidos en",
  "   `research/scoping-review/manifests/manual-exports.csv`.",
  "3. Si hay varios lotes, añadir filas con sufijos `B002`, `B003`, etc., sin",
  "   combinar ni editar las exportaciones originales.",
  "4. Completar fecha, total comunicado, indicador de completitud, índices de",
  "   Web of Science e incidencias. Cambiar a `READY` solo cuando el archivo",
  "   correspondiente esté en su ruta.",
  "5. Ejecutar:",
  "",
  "```powershell",
  "Rscript --vanilla scripts/26_import_manual_scoping_exports.R",
  "Rscript --vanilla scripts/27_build_scoping_corpus.R",
  "Rscript --vanilla scripts/28_validate_scoping_seeds.R",
  "Rscript --vanilla scripts/29_build_scoping_prisma.R",
  "Rscript --vanilla scripts/30_prepare_scoping_search_pilot.R",
  "```",
  "",
  "Los RIS se consideran respuestas brutas inmutables y quedan excluidos de",
  "Git. Durante la importación se registran SHA-256, número de filas y fecha.",
  "El pipeline conserva base, línea, estrategia, lote, archivo e identificador",
  "original antes de deduplicar."
)

output <- file.path(
  project_root, "research", "scoping-review", "strategies",
  "manual-search-runbook.md"
)
writeLines(lines, output, useBytes = TRUE)
message("Manual search runbook written to: ", relative_project_path(output))
