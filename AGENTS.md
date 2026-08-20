# AGENTS.md — PaRISEHIS Harmonisation Project

## Misión

Desarrollar y validar una armonización retrospectiva transparente entre PaRIS
Cycle 1 y EHIS Wave 3. La semejanza textual o distributiva nunca basta para
declarar equivalencia.

## Reglas no negociables

- No subir a Git microdatos, datos individuales derivados, credenciales,
  documentación restringida ni resultados que incumplan disclosure.
- Tratar `data/raw` como inmutable. Leer de `raw`; escribir en `interim`,
  `processed`, `outputs` o `logs`.
- No hardcodear rutas. Usar `scripts/00_setup.R` y `config/paths.R`.
- Mantener separadas armonización conceptual y validación empírica.
- No inferir equivalencia por nombre, similitud semántica o distribuciones.
- Toda variable armonizada debe ser trazable a fuente, mapping, algoritmo,
  versión de datos y commit.
- No colapsar automáticamente ausencia estructural, no aplicable, rechazo,
  desconocido y no recogido.
- Respetar pesos, estratos y conglomerados cuando existan.

## Convenciones

- Código y campos: inglés, `snake_case`, UTF-8. Documentación científica:
  español, conservando el texto original de las preguntas.
- Funciones reutilizables en `R/`; orquestación numerada en `scripts/`.
- Cada script comienza con `source("scripts/00_setup.R")`.
- Las funciones puras nuevas incluyen tests con datos sintéticos.
- Decisiones científicas en `harmonisation/decisions/decision_log.csv`.
- Actualizar `CHANGELOG.md` cuando cambien estructura, criterios, mappings,
  algoritmos o resultados relevantes.

## Modelo mínimo

`domain -> concept -> measure -> source_variable -> assessment ->
target_variable -> algorithm -> harmonised_variable`

Cada assessment separa concepto, medida, población/universo, periodo,
representación, derivación y administración. Clases: `DIRECT`, `RECODABLE`,
`DERIVABLE`, `PARTIAL`, `RELATED`, `NONE`. Estados: `PROPOSED`, `REVIEWED`,
`VALIDATED`, `REJECTED`, `UNRESOLVED`.

## Búsqueda metodológica

- Registrar base, fecha, consulta exacta, filtros y objetivo.
- Documentar inclusión y exclusión en tablas versionadas.
- Priorizar OECD, Eurostat, DDI, ISO y publicaciones metodológicas primarias.
- Los métodos automáticos solo generan candidatos; requieren revisión humana.

## Antes de cerrar una tarea

1. Ejecutar pruebas pertinentes.
2. Verificar que `git status` no incluye datos ni secretos.
3. Confirmar que outputs son regenerables.
4. Actualizar documentación y changelog para decisiones persistentes.
