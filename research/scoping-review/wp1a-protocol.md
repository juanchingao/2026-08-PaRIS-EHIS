# WP1A — Retrospective harmonisation methodology

**Versión:** 1.0-draft  
**Fecha:** 2026-09-01  
**Estado:** `REQUIRES_REVIEW`

## Pregunta

> ¿Qué métodos, criterios y procedimientos se utilizan para diseñar, ejecutar
> y validar la armonización retrospectiva de variables procedentes de
> encuestas, cohortes y otros estudios de salud?

WP1A responde **cómo armonizar** y producirá un *methodological rulebook*. El
protocolo metodológico v0.2, las líneas A/B/C, las ejecuciones y el corpus
histórico se conservan íntegros. Los identificadores antiguos no se modifican;
`strategies/search-id-crosswalk.csv` añade únicamente aliases y etiquetas.

## Alcance

Incluye armonización retrospectiva y entre estudios, mapping de variables,
equivalencia semántica, operacional y de cuestionarios, invariancia, DIF,
linking, métricas comunes, calibración, análisis integrativo o agrupado,
validación, incertidumbre y sensibilidad. IRT, DIF, linking o equiparación solo
son pertinentes cuando existen constructos y anclajes defendibles.

## Estrategias históricas y ampliación candidata

- Originales: `NR-PUBMED-01` y `NR-PUBMED-02`, conservadas literalmente en
  `../narrative-review/search-strategies.csv`.
- Clasificación nueva: `WP1A-PUBMED-01` y `WP1A-PUBMED-02` como aliases.
- Traducciones fieles WoS: `WP1A-WOS-01` y `WP1A-WOS-02`, restringidas a
  `TI` y `AB`.
- Candidata v2.0: añade *cross-study comparability*, *construct/variable
  harmonisation*, *data pooling*, *questionnaire linking*, *calibration*,
  *commensurate measures*, *integrative data analysis* y *pooled analysis*.
  Permanece `REQUIRES_REVIEW`.

La ampliación v2.0 aumenta previsiblemente la sensibilidad para trabajos que
no usan la palabra *harmonisation*, pero puede reducir mucho la precisión por
la polisemia de *calibration*, *pooling* y *pooled analysis*. Es un cambio
material: si se aprueba, requiere nueva versión y ejecuciones separadas, nunca
una mezcla silenciosa con v0.2/v0.3.

## Fuentes y validación

PubMed, Scopus, Embase y Web of Science son fuentes bibliográficas. La
validación exige sintaxis, recuento, muestras por relevancia y fecha, y
recuperación de artículos centinela. La aceptación técnica de una consulta no
equivale a validación científica. JBI guía el diseño; PRISMA-ScR el reporte,
PRISMA-S la documentación y PRESS la revisión externa.

