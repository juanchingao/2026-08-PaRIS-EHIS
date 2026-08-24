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

## Estado actual (2026-08-24)

- El alcance está en reorientación. OECD publicó el 15 de julio de 2026 el
  policy paper `10.1787/acf46da9-en`, que ya compara PaRIS, EHIS, IHP, PVS y
  SHARE mediante mapeo de dominios, crosswalk, recodificación, restricción
  poblacional y postestratificación.
- La propuesta activa es una réplica metodológica y análisis de robustez de la
  comparación PaRIS–EHIS, inicialmente para salud autopercibida y
  hospitalización. El protocolo de trabajo es
  `documentation/protocol/protocol.md`.
- R2, la corrida LLM, la ampliación masiva del mapping y nuevos cambios de la
  web de cribado están en pausa hasta confirmación del nuevo alcance.

- Metadatos normalizados: 195 variables PaRIS Cycle 1 y 154 variables EHIS
  Wave 3; EHIS Wave 2 se conserva como apoyo histórico.
- Revisión narrativa: 813 registros PubMed recuperados, 121 revisados por
  título/resumen, 35 incluidos y 15 fuentes nucleares extraídas; las 121
  decisiones fueron ratificadas por el investigador.
- Suplemento Scopus: 1.178 registros únicos, 443 coincidentes con PubMed y 735
  candidatos exclusivos pendientes de priorización y cribado humano.
- Suplemento Embase: 879 registros únicos importados desde RIS, 644 coincidentes
  con PubMed o Scopus y 235 nuevos; corpus combinado de 1.783 registros únicos.
- Cribado suplementario finalizado: 970 filas, de las que 15 están marcadas
  como copias de 14 grupos duplicados; corpus efectivo de 955 referencias, con
  68 `INCLUDE`, 332 `BACKGROUND` y 555 `EXCLUDE`. Sumado al cribado PubMed, hay
  1.076 referencias únicas cribadas: 103 `INCLUDE`, 361 `BACKGROUND` y 612
  `EXCLUDE`. Ninguna prioridad ni propuesta algorítmica equivale por sí sola a
  decisión humana.
- Sitio público Quarto multipágina desplegado mediante Workers Static Assets en
  `https://paris-ehis-progress.paris-ehis.workers.dev`, con landing, referencias
  públicas y protocolo anotable. El build público excluye abstracts licenciados.
- Worker y base D1 creados para doble revisión cegada, adjudicación y agente
  automático. D1 contiene 1.091 filas bibliográficas, 1.091 decisiones JALR y
  891 propuestas automáticas. Cloudflare Access OTP protege `/api/*` mediante
  una allowlist exacta para JALR e investigador 2.
- Las guías Maelstrom estructuran el ciclo del proyecto; el modelo dimensional,
  las clases y la prohibición de inferir equivalencia siguen siendo específicos
  y vinculantes para PaRIS–EHIS.
- El protocolo v0.1 queda como antecedente histórico. Todavía no existen
  mappings source-to-target validados ni algoritmos aplicados a microdatos.
- Último punto de reentrada: `documentation/planning/next-steps.md`.

## Prioridad al retomar

1. Confirmar o modificar el alcance de réplica y robustez del protocolo v0.2.
2. Inventariar acceso, versiones, hashes, licencias y variables de diseño de los
   microdatos necesarios para los trece países candidatos.
3. Reconstruir y congelar la especificación OECD para salud autopercibida y
   hospitalización sin consultar distribuciones propias.
4. Aclarar definiciones, pesos, celdas, missingness y tablas numéricas con OECD
   cuando sea posible.
5. Completar el assessment preestadístico de los dos indicadores primarios y
   someterlo a segunda revisión.
6. Mantener algoritmos PaRIS y EHIS independientes, con tests sintéticos, antes
   de ejecutar la réplica o cualquier sensibilidad.

No utilizar IRT, linking o equiparación por defecto. Solo considerarlos cuando
exista constructo común, ítems compartidos, muestra puente u otro anclaje
defendible, además de evidencia de invariancia y análisis de sensibilidad.

## Antes de cerrar una tarea

1. Ejecutar pruebas pertinentes.
2. Verificar que `git status` no incluye datos ni secretos.
3. Confirmar que outputs son regenerables.
4. Actualizar documentación y changelog para decisiones persistentes.
