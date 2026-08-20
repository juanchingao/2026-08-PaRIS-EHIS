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

## Estado actual (2026-08-20)

- Metadatos normalizados: 195 variables PaRIS Cycle 1 y 154 variables EHIS
  Wave 3; EHIS Wave 2 se conserva como apoyo histórico.
- Revisión narrativa: 813 registros PubMed recuperados, 121 revisados por
  título/resumen, 35 incluidos y 15 fuentes nucleares extraídas.
- La clasificación bibliográfica inicial requiere confirmación del
  investigador antes de presentarse como selección definitiva.
- Protocolo y framework siguen en versión de trabajo; todavía no existen
  mappings source-to-target validados ni algoritmos aplicados a microdatos.
- Último punto de reentrada: `documentation/planning/next-steps.md`.

## Prioridad al retomar

1. No ampliar todavía el mapping a todas las variables.
2. Formalizar valores controlados y reglas de decisión para las siete
   dimensiones de compatibilidad.
3. Ejecutar un piloto con edad, sexo/género, salud autopercibida, diabetes,
   utilización sanitaria, una escala compartida y un PREM PaRIS sin equivalente.
4. Definir cada variable objetivo antes de asignar variables fuente.
5. Mantener algoritmos PaRIS y EHIS independientes, con tests sintéticos.
6. Incorporar microdatos solo después de inventariar archivos, hashes,
   licencias, códigos de ausencia y componentes del diseño muestral.

No utilizar IRT, linking o equiparación por defecto. Solo considerarlos cuando
exista constructo común, ítems compartidos, muestra puente u otro anclaje
defendible, además de evidencia de invariancia y análisis de sensibilidad.

## Antes de cerrar una tarea

1. Ejecutar pruebas pertinentes.
2. Verificar que `git status` no incluye datos ni secretos.
3. Confirmar que outputs son regenerables.
4. Actualizar documentación y changelog para decisiones persistentes.
