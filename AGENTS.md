# AGENTS.md — PaRIS International Harmonisation Project

## Misión

Desarrollar y evaluar un framework reproducible y escalable de armonización
retrospectiva entre PaRIS Cycle 1 y otras encuestas internacionales de salud.
PaRIS es la encuesta índice y EHIS Wave 3 el primer comparador. La semejanza
textual o distributiva nunca basta para declarar equivalencia.

## Reglas no negociables

- No subir a Git microdatos, datos individuales derivados, credenciales,
  documentación restringida ni resultados que incumplan disclosure.
- Tratar `data/raw` como inmutable. Leer de `raw`; escribir en `interim`,
  `processed`, `outputs` o `logs`.
- No hardcodear rutas. Usar `scripts/00_setup.R` y `config/paths.R`.
- Mantener separadas armonización conceptual, generación técnica y validación
  empírica.
- No inferir equivalencia por nombre, similitud semántica o distribuciones.
- Toda variable armonizada debe ser trazable a fuente, mapping, algoritmo,
  versión de datos y commit.
- No colapsar automáticamente ausencia estructural, no aplicable, rechazo,
  desconocido y no recogido.
- Respetar pesos, estratos, conglomerados y niveles adicionales cuando existan.
- Estimar primero dentro de encuesta y país; no tratar microdatos concatenados
  como si procedieran de una única muestra.

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

Cada assessment separa como mínimo concepto, medida, población/universo,
periodo, representación, derivación y administración. También registra
redacción, filtros, contexto del cuestionario, adaptaciones nacionales y pérdida
de información cuando sean relevantes.

Clases técnicas: `DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED`,
`NONE`. Potencial: `IDENTICAL`, `COMPATIBLE`, `PARTIALLY_COMPATIBLE`,
`INCOMPATIBLE`, `UNAVAILABLE`. Estados: `PROPOSED`, `REVIEWED`, `VALIDATED`,
`REJECTED`, `UNRESOLVED`.

## Selección de encuestas

- Núcleo: PaRIS Cycle 1 y EHIS Wave 3.
- Ampliación prioritaria, tras el piloto: SHARE e IHP.
- Validación o extensiones justificadas: CCHS, EU-SILC, MEPS, HRS, BRFSS y PVS.
- No incorporar una fuente sin documentar relevancia, población, cobertura,
  microdatos, cuestionario, diccionario, diseño, licencia y ganancia científica.
- No ampliar automáticamente el análisis primario a todas las encuestas.

## Scoping review metodológica

- WP1 sigue JBI para diseño y ejecución y PRISMA-ScR para reporte.
- Registrar base, plataforma, fecha, consulta exacta, campos, filtros, límites,
  recuento y objetivo.
- Documentar inclusión, exclusión y adjudicación en tablas versionadas.
- Priorizar fuentes metodológicas primarias y documentación oficial.
- El corpus narrativo previo es una búsqueda piloto; sus decisiones no se
  transfieren automáticamente a WP1.
- Los métodos automáticos solo generan candidatos; requieren revisión humana.

## Estado actual (2026-08-24)

- El protocolo canónico v0.3 propone un framework multifuente. Está pendiente
  de aprobación formal por JALR.
- OECD 2026 `10.1787/acf46da9-en` es antecedente directo y benchmark; la réplica
  PaRIS–EHIS de salud autopercibida y hospitalización se conserva como parte del
  piloto, no como finalidad exclusiva.
- WP1 dispone de protocolo, auditoría de búsquedas, cobertura conceptual y
  plantilla de extracción, todos en estado propuesto y no ejecutado.
- Existe un inventario inicial de diez encuestas. La disponibilidad real de
  microdatos, variables de diseño, países y versiones sigue pendiente salvo la
  documentación local registrada de PaRIS y EHIS.
- Metadatos normalizados: 195 variables PaRIS Cycle 1 y 154 variables EHIS Wave
  3; EHIS Wave 2 se conserva como apoyo histórico.
- El corpus previo contiene 1.076 referencias únicas cribadas y se conserva con
  sus decisiones JALR, infraestructura D1 y trazabilidad.
- Todavía no existen mappings source-to-target validados ni algoritmos aplicados
  a microdatos.
- Punto de reentrada: `documentation/planning/next-steps.md`.

## Prioridad al retomar

1. Aprobar o modificar el protocolo v0.3 y registrar las decisiones propuestas.
2. Congelar y registrar el protocolo WP1; validar las estrategias ampliadas con
   artículos centinela antes de ejecutarlas.
3. Completar el inventario legal y técnico de PaRIS y EHIS.
4. Definir el DataSchema mínimo viable antes de asignar variables fuente.
5. Ejecutar un piloto pequeño PaRIS–EHIS con revisión independiente.
6. Implementar algoritmos separados y tests sintéticos antes de microdatos.
7. Evaluar el piloto antes de decidir la incorporación de SHARE o IHP.

No utilizar IRT, linking, DIF o equiparación por defecto. Solo considerarlos
cuando exista constructo común, ítems compartidos, muestra puente u otro anclaje
defendible, además de evidencia de invariancia y análisis de sensibilidad.

## Antes de cerrar una tarea

1. Ejecutar pruebas pertinentes.
2. Verificar que `git status` no incluye datos ni secretos.
3. Confirmar que outputs son regenerables.
4. Actualizar documentación y changelog para decisiones persistentes.
