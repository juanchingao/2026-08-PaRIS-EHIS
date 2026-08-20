# PaRISEHIS Harmonisation Project

Armonización retrospectiva de **PaRIS Cycle 1** y **European Health Interview
Survey (EHIS) Wave 3** mediante un modelo común de conceptos, medidas,
poblaciones, representaciones y variables objetivo.

El objetivo no es maximizar correspondencias, sino establecer de forma
reproducible qué variables pueden compararse, bajo qué transformaciones y en
qué poblaciones. Una conclusión de no comparabilidad es un resultado válido.

## Estado

Infraestructura inicial. El protocolo está en versión 0.1 y aún no se han
incorporado microdatos ni inventarios reales de variables.

## Arquitectura

```text
├── R/                         # funciones reutilizables
├── scripts/                   # pipeline numerado
├── config/                    # rutas y configuración científica
├── data/
│   ├── raw/{paris,ehis}/      # originales inmutables; nunca se versionan
│   ├── interim/               # datos temporales; no se versionan
│   ├── processed/             # datos analíticos; no se versionan
│   └── metadata/              # metadatos normalizados versionables
├── harmonisation/
│   ├── catalogues/            # dominios, conceptos y variables objetivo
│   ├── mappings/              # source variable -> target variable
│   ├── algorithms/            # reglas de transformación
│   └── decisions/             # decisiones documentadas
├── research/{searches,sources}/
├── documentation/{protocol,methods}/
├── reports/                   # informes reproducibles
├── manuscript/                # futuro manuscrito
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
5. Deposite originales sin modificar en `data/raw/paris/` y `data/raw/ehis/`,
   o en la ruta externa configurada.

No deben usarse rutas absolutas. `PARISEHIS_RAW_DIR`,
`PARISEHIS_INTERIM_DIR`, `PARISEHIS_DERIVED_DIR`, `PARISEHIS_OUTPUTS_DIR` y
`PARISEHIS_LOGS_DIR` adaptan la ejecución a Windows, Ubuntu o un entorno seguro.

## Flujo previsto

1. Búsqueda metodológica y adquisición documental.
2. Inventario y normalización de metadatos.
3. Catálogo de dominios, conceptos, medidas y universos.
4. Definición de variables objetivo y evaluación de mappings.
5. Algoritmos por fuente, control de calidad y validación empírica.
6. Sensibilidad y comparabilidad poblacional.

## Documentos clave

- [Protocolo v0.1](documentation/protocol/protocol-v0.1.md)
- [Protocolo de revisión narrativa metodológica](research/narrative-review/protocol.md)
- [Revisión narrativa metodológica v0.1](research/narrative-review/narrative-review-v0.1.md)
- [Siguientes pasos y punto de reentrada](documentation/planning/next-steps.md)
- [Plan de búsqueda](research/searches/README.md)
- [Modelo de datos](documentation/methods/data-model.md)
- [Procesamiento de reglas de anonimización EHIS](documentation/methods/ehis-anonymisation-processing.md)
- [Procesamiento del codebook PaRIS](documentation/methods/paris-codebook-processing.md)
- [Registro de cambios](CHANGELOG.md)
- [Instrucciones para agentes](AGENTS.md)

## Seguridad

Los microdatos y materiales sujetos a licencia permanecen fuera de Git. Antes
de usar una fuente se documentarán licencia, almacenamiento, disclosure y
requisitos éticos. `raw` es inmutable; las transformaciones se escriben en
`interim` o `processed`.
