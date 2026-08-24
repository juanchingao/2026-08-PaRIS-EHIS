# PaRISEHIS Harmonisation Project

Armonización retrospectiva de **PaRIS Cycle 1** y **European Health Interview
Survey (EHIS) Wave 3** mediante un modelo común de conceptos, medidas,
poblaciones, representaciones y variables objetivo.

El objetivo no es maximizar correspondencias, sino establecer de forma
reproducible qué variables pueden compararse, bajo qué transformaciones y en
qué poblaciones. Una conclusión de no comparabilidad es un resultado válido.

## Estado

El proyecto está en **reorientación científica** desde el 24 de agosto de 2026.
El informe OECD 2026 `10.1787/acf46da9-en` ya ejecuta la comparación general
PaRIS–EHIS que motivaba el protocolo inicial. La propuesta activa es una réplica
independiente y análisis de robustez para salud autopercibida y hospitalización.

La búsqueda bibliográfica multibase, las 1.076 decisiones JALR, la interfaz de
doble revisión y el lote LLM se conservan, pero están en pausa. Se han
normalizado 195 variables PaRIS Cycle 1 y 154 variables EHIS Wave 3; todavía no
se han incorporado microdatos ni validado mappings source-to-target.

## Arquitectura

```text
├── R/                         # funciones reutilizables
├── scripts/                   # pipeline numerado
├── config/                    # rutas y configuración científica
├── data/
│   ├── raw/{paris,ehis,documentation}/
│   │                           # originales inmutables; nunca se versionan
│   ├── interim/               # datos temporales; no se versionan
│   ├── processed/             # datos analíticos; no se versionan
│   └── metadata/              # metadatos normalizados versionables
├── harmonisation/
│   ├── catalogues/            # dominios, conceptos y variables objetivo
│   ├── mappings/              # source variable -> target variable
│   ├── algorithms/            # reglas de transformación
│   └── decisions/             # decisiones documentadas
├── research/                  # revisión vigente y material histórico archivado
├── documentation/            # protocolo, métodos, planificación e inventarios
├── reports/                   # informes reproducibles
├── manuscript/                # futuro manuscrito
├── website/                   # sitio Quarto multipágina para Cloudflare Workers
├── outputs/{tables,figures}/  # resultados regenerables
├── tests/testthat/            # pruebas sin microdatos
└── logs/                      # registros de ejecución
```

## Puesta en marcha

1. Clone el repositorio en Ubuntu y ábralo desde RStudio Server.
2. Copie `.Renviron.example` a `.Renviron` y adapte rutas solo si los datos no
   residen dentro del repositorio.
3. Ejecute `renv::restore()`.
4. Compruebe el entorno con `source("scripts/01_validate_environment.R")`.
5. Deposite microdatos sin modificar en `data/raw/paris/` y `data/raw/ehis/`.
   La documentación fuente local se organiza por encuesta bajo
   `data/raw/documentation/`, o en la ruta externa configurada.

No deben usarse rutas absolutas. `PARISEHIS_RAW_DIR`,
`PARISEHIS_INTERIM_DIR`, `PARISEHIS_DERIVED_DIR`, `PARISEHIS_OUTPUTS_DIR` y
`PARISEHIS_LOGS_DIR` adaptan la ejecución a Windows, Ubuntu o un entorno seguro.

### Búsqueda en Scopus (flujo en pausa)

La búsqueda requiere una clave de la API de Elsevier. Guárdela únicamente en
el `.Renviron` local, que está excluido de Git:

```text
SCOPUS_API_KEY=replace_with_your_elsevier_api_key
```

Compruebe primero los recuentos, sin recuperar registros completos:

```r
Rscript --vanilla scripts/09_search_scopus_narrative_review.R --count-only
```

Si la institución exige autenticación adicional fuera de su red, añada
`SCOPUS_INST_TOKEN` al mismo archivo. Nunca registre ni imprima ninguna clave.

## Flujo previsto

1. Búsqueda metodológica y adquisición documental.
2. Inventario y normalización de metadatos.
3. Catálogo de dominios, conceptos, medidas y universos.
4. Definición de variables objetivo y evaluación de mappings.
5. Algoritmos por fuente, control de calidad y validación empírica.
6. Sensibilidad y comparabilidad poblacional.

## Documentos clave

- [Índice de documentación](documentation/README.md)
- [Protocolo vigente: réplica y robustez](documentation/protocol/protocol.md)
- [Evaluación del informe OECD 2026](documentation/protocol/sources/oecd-2026-comparison-assessment.md)
- [Protocolo v0.1 histórico](documentation/protocol/archive/protocol-v0.1.md)
- [Protocolo de revisión narrativa metodológica](research/narrative-review/protocol.md)
- [Revisión narrativa metodológica v0.1, histórica](research/narrative-review/archive/narrative-review-v0.1.md)
- [Siguientes pasos y punto de reentrada](documentation/planning/next-steps.md)
- [Protocolo para comité de ética v0.1](documentation/ethics/ethics-protocol-v0.1.md)
- [Versión Quarto del protocolo ético](reports/ethics-protocol.qmd)
- [Índice de investigación](research/README.md)
- [Mapa de scripts](scripts/README.md)
- [Modelo de datos](documentation/methods/data-model.md)
- [Procesamiento de reglas de anonimización EHIS](documentation/methods/ehis-anonymisation-processing.md)
- [Procesamiento del codebook PaRIS](documentation/methods/paris-codebook-processing.md)
- [Alineación con Maelstrom Research](documentation/methods/maelstrom-alignment.md)
- [Gobernanza del doble cribado y agente automático](documentation/methods/screening-governance.md)
- [Arquitectura privada en Cloudflare](cloudflare/README.md)
- [Registro de cambios](CHANGELOG.md)
- [Instrucciones para agentes](AGENTS.md)
- [Hoja de ruta de la web pública](documentation/planning/public-website-roadmap.md)
- [Instrucciones del sitio público](website/README.md)
- [Web pública desplegada](https://paris-ehis-progress.paris-ehis.workers.dev)

## Seguridad

Los microdatos y materiales sujetos a licencia permanecen fuera de Git. Antes
de usar una fuente se documentarán licencia, almacenamiento, disclosure y
requisitos éticos. `raw` es inmutable; las transformaciones se escriben en
`interim` o `processed`.
