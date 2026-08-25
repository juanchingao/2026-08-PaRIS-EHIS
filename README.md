# PaRIS International Harmonisation Project

Framework reproducible para evaluar y ejecutar la armonización retrospectiva de
**PaRIS Cycle 1** con otras encuestas internacionales de salud. PaRIS es la
encuesta índice y **EHIS Wave 3** el primer comparador.

El objetivo no es maximizar correspondencias ni combinar indiscriminadamente
microdatos. El proyecto determinará, variable por variable, qué puede generarse,
mediante qué transformaciones, para qué población y con qué grado de
comparabilidad conceptual y empírica. La no comparabilidad es un resultado
válido.

## Estado

El protocolo v0.3 está en **reformulación científica pendiente de aprobación**.
El informe OECD 2026 `10.1787/acf46da9-en` ya comparó PaRIS, EHIS, SHARE, IHP y
PVS mediante mapeo de dominios, crosswalks y algunas comparaciones
estandarizadas. Por ello, el vacío no es un nuevo crosswalk descriptivo, sino la
implementación reproducible de un DataSchema, algoritmos auditables y una
evaluación de equivalencia y transportabilidad.

El producto mínimo viable se limita a PaRIS–EHIS. SHARE e IHP son ampliaciones
prioritarias posteriores. CCHS, EU-SILC, MEPS, HRS, BRFSS y PVS solo se
considerarán para validaciones o extensiones justificadas.

WP1 será una scoping review sistemática conforme a JBI y PRISMA-ScR. El corpus
multibase previo —1.076 referencias únicas con decisiones JALR— se conserva como
búsqueda piloto, pero no constituye automáticamente la selección de WP1.

## Arquitectura

```text
├── R/                         # funciones reutilizables
├── scripts/                   # pipeline numerado
├── config/                    # configuración científica y rutas
├── data/
│   ├── raw/                   # originales inmutables; nunca se versionan
│   ├── interim/               # datos temporales; no se versionan
│   ├── processed/             # datos analíticos; no se versionan
│   └── metadata/              # metadatos normalizados versionables
├── harmonisation/
│   ├── catalogues/            # dominios, conceptos y DataSchema
│   ├── templates/             # plantillas de DataSchema y equivalencia
│   ├── mappings/              # source variable -> target variable
│   ├── algorithms/            # reglas específicas por fuente
│   └── decisions/             # decisiones científicas
├── research/
│   ├── scoping-review/        # WP1 activo propuesto
│   └── narrative-review/      # búsqueda piloto y corpus previo
├── documentation/            # protocolo, métodos, planificación e inventarios
├── website/                   # sitio Quarto y páginas públicas
├── outputs/{tables,figures}/  # resultados regenerables
├── tests/testthat/            # pruebas con datos sintéticos
└── logs/                      # registros de ejecución
```

## Flujo previsto

1. Scoping review metodológica.
2. Selección e inventario legal y técnico de encuestas.
3. Definición independiente del DataSchema.
4. Assessment multidimensional por dos revisores.
5. Algoritmos independientes por fuente con tests sintéticos.
6. Piloto PaRIS–EHIS respetando cada diseño muestral.
7. Evaluación distributiva, nomológica y de transportabilidad.
8. Decisión prospectiva sobre SHARE, IHP y extensiones.

Las estimaciones se producirán primero dentro de cada encuesta y país. Una
estructura común no convierte todas las observaciones en una única muestra.

## Puesta en marcha

1. Clone el repositorio y ábralo desde la raíz del proyecto.
2. Copie `.Renviron.example` a `.Renviron` solo si necesita variables locales.
3. Ejecute `renv::restore()`.
4. Compruebe el entorno con `Rscript --vanilla scripts/01_validate_environment.R`.
5. Deposite originales autorizados en `data/raw/` o configure almacenamiento
   externo mediante las variables documentadas en `config/paths.R`.

No deben usarse rutas absolutas en código. Las claves API se almacenan
únicamente en `.Renviron`, que está excluido de Git.

## Documentos clave

- [Protocolo v0.3](documentation/protocol/protocol.md)
- [Protocolo WP1 de la scoping review](research/scoping-review/protocol.md)
- [Auditoría de búsquedas](research/scoping-review/search-strategy-audit.md)
- [Inventario de encuestas](documentation/inventories/survey-inventory.csv)
- [Preguntas y objetivos](documentation/planning/research-questions.csv)
- [Cronograma por Work Packages](documentation/planning/work-packages.csv)
- [Riesgos y asuntos pendientes](documentation/planning/risk-register.csv)
- [Modelo de datos](documentation/methods/data-model.md)
- [Alineación Maelstrom](documentation/methods/maelstrom-alignment.md)
- [Evaluación del informe OECD 2026](documentation/protocol/sources/oecd-2026-comparison-assessment.md)
- [Punto de reentrada](documentation/planning/next-steps.md)
- [Registro de decisiones](harmonisation/decisions/decision_log.csv)
- [Mapa de scripts](scripts/README.md)
- [Registro de cambios](CHANGELOG.md)

## Seguridad

Los microdatos y materiales sujetos a licencia permanecen fuera de Git. Antes
de usar una fuente se documentarán licencia, almacenamiento, disclosure y
requisitos éticos. `data/raw` es inmutable; las transformaciones se escriben en
`interim` o `processed`. Los productos públicos serán principalmente
documentación, metadatos, código, algoritmos y resultados agregados aprobados.
