# Scoping review metodológica (WP1)

Este directorio contiene el Work Package 1 activo. El diseño sigue JBI, el
informe seguirá PRISMA-ScR, la búsqueda se documentará con PRISMA-S y la
estrategia principal se preparará para revisión PRESS.

## Componentes canónicos

- `protocol.md`: protocolo v0.2.
- `search-strategy-audit.md`: auditoría del corpus histórico y de las API.
- `search-strategies-draft.csv`: antecedente v0.1; no borrar ni ejecutar como
  estrategia vigente.
- `strategies/search-strategies-v0.2.csv`: ecuaciones A/B/C por plataforma.
- `strategies/strategy-register.csv`: versión, estado y ejecución por estrategia.
- `strategies/concept-term-matrix.csv`: relación entre pregunta, conceptos,
  términos, elegibilidad y extracción.
- `seed-references.csv` y `seed-validation.csv`: conjunto de sensibilidad y
  resultados de recuperación por base y línea.
- `grey-literature-template.csv` y `grey-literature-log.csv`: búsqueda dirigida.
- `grey-literature-sources.csv`: fuentes predefinidas, rutas y criterios de
  detención antes de ejecutar la literatura gris.
- `citation-chasing-log.csv`: rastreo hacia atrás, delante y por grupos.
- `press-review-form.md`: plantilla para la revisión externa de la estrategia.
- `extraction-template.csv`: formulario de charting.
- `api-audit.md`: proveedor, endpoints, autenticación y limitaciones verificadas.
- `manifests/search-runs.csv`: inventario versionable de ejecuciones y hashes.
- `manifests/scopus-subqueries.csv`: consultas atómicas realmente ejecutadas,
  paginación, recuentos y checksums de Scopus.
- `reports/`: resúmenes reproducibles sin contenido bibliográfico restringido.

En Scopus, la tabla de estrategias conserva la ecuación matriz legible. La API
se ejecuta mediante bloques lógicamente equivalentes para respetar su parser y
su ventana de resultados; las 18 ecuaciones efectivas están congeladas en el
manifiesto de subconsultas.

## Ejecución

Todos los scripts se ejecutan desde la raíz del repositorio:

```powershell
Rscript --vanilla scripts/22_validate_scoping_searches.R
Rscript --vanilla scripts/23_run_pubmed_scoping_searches.R
Rscript --vanilla scripts/24_run_scopus_scoping_searches.R
Rscript --vanilla scripts/25_test_embase_scoping_searches.R
Rscript --vanilla scripts/26_import_manual_scoping_exports.R
Rscript --vanilla scripts/27_build_scoping_corpus.R
Rscript --vanilla scripts/28_validate_scoping_seeds.R
Rscript --vanilla scripts/29_build_scoping_prisma.R
Rscript --vanilla scripts/30_prepare_scoping_search_pilot.R
```

El último script crea una muestra ciega de 150 registros en `outputs/` para
estimar relevancia por base y línea. No asigna decisiones ni sustituye el
cribado humano.

Las respuestas se escriben en rutas configuradas por `config/paths.R`:

- `data/raw/scoping-review/`: respuestas originales inmutables;
- `data/interim/scoping-review/`: registros normalizados;
- `data/processed/scoping-review/`: obras, procedencias y decisiones de
  deduplicación;
- `logs/scoping-review/`: eventos de ejecución;
- `outputs/tables/scoping-review/`: tablas PRISMA y controles.

Estas rutas generadas están excluidas de Git. Los manifiestos versionables no
contienen abstracts restringidos ni credenciales.

## Corpus histórico

`../narrative-review/` se conserva sin cambios como búsqueda piloto. Sus
decisiones no se transfieren automáticamente porque la pregunta y la
elegibilidad han cambiado. Los archivos brutos licenciados permanecen fuera de
Git.

## Credenciales

Se leen únicamente desde variables de entorno (`SCOPUS_API_KEY`,
`EMBASE_API_KEY`, y opcionalmente `EMBASE_INST_TOKEN`, `NCBI_API_KEY`,
`NCBI_EMAIL`, `WOS_API_KEY`). Nunca se escriben en consultas, logs, manifiestos
ni mensajes de error.
