# Ejecución manual: Embase.com, APA PsycINFO y Web of Science

**Versión del documento maestro:** 0.3
**Generado:** 2026-08-28
**Regla:** ejecutar A, B y C por separado, sin unirlas mediante `AND`.

No aplicar filtros de fecha, idioma, humanos o tipo documental. Anotar el
total mostrado antes de exportar. Si la plataforma limita el tamaño de cada
exportación, crear lotes consecutivos sin solapamientos.

## Embase.com

La versión actual usa texto libre en `:ti,ab,kw`. Los descriptores
Emtree solo se añadirán después de verificarlos en Embase.com.

### Línea A — `SR-EMBASE-A`

Versión de estrategia: 0.2.

Campos: title; abstract; author keywords. Filtros: None.

```text
('data harmonization':ti,ab,kw OR 'data harmonisation':ti,ab,kw OR 'retrospective harmonization':ti,ab,kw OR 'retrospective harmonisation':ti,ab,kw OR 'ex post harmonization':ti,ab,kw OR 'ex-post harmonization':ti,ab,kw OR 'ex post harmonisation':ti,ab,kw OR 'ex-post harmonisation':ti,ab,kw OR 'post hoc harmonization':ti,ab,kw OR 'post hoc harmonisation':ti,ab,kw OR 'pooled data harmonization':ti,ab,kw OR 'pooled data harmonisation':ti,ab,kw OR 'individual-level data harmonization':ti,ab,kw OR 'individual-level data harmonisation':ti,ab,kw OR 'variable harmonization':ti,ab,kw OR 'variable harmonisation':ti,ab,kw OR 'survey harmonization':ti,ab,kw OR 'survey harmonisation':ti,ab,kw OR 'questionnaire harmonization':ti,ab,kw OR 'questionnaire harmonisation':ti,ab,kw OR 'semantic harmonization':ti,ab,kw OR 'semantic harmonisation':ti,ab,kw) AND (survey*:ti,ab,kw OR questionnaire*:ti,ab,kw OR cohort*:ti,ab,kw OR epidemiolog*:ti,ab,kw OR 'population health':ti,ab,kw OR 'health survey':ti,ab,kw OR 'health surveys':ti,ab,kw OR 'patient-reported measure':ti,ab,kw OR 'patient-reported measures':ti,ab,kw OR 'patient reported measure':ti,ab,kw OR 'patient reported measures':ti,ab,kw OR 'cross-national':ti,ab,kw OR 'cross-country':ti,ab,kw OR multicountry:ti,ab,kw OR 'multi-country':ti,ab,kw)
```

### Línea B — `SR-EMBASE-B`

Versión de estrategia: 0.2.

Campos: title; abstract; author keywords. Filtros: None.

```text
('measurement equivalence':ti,ab,kw OR 'measurement invariance':ti,ab,kw OR 'construct equivalence':ti,ab,kw OR 'conceptual equivalence':ti,ab,kw OR 'semantic equivalence':ti,ab,kw OR 'functional equivalence':ti,ab,kw OR 'item equivalence':ti,ab,kw OR 'question comparability':ti,ab,kw OR 'questionnaire comparability':ti,ab,kw OR 'cross-survey comparability':ti,ab,kw OR 'cross-cultural comparability':ti,ab,kw OR 'common metric':ti,ab,kw OR 'scale linking':ti,ab,kw OR 'score linking':ti,ab,kw OR 'test equating':ti,ab,kw OR crosswalk*:ti,ab,kw OR 'item mapping':ti,ab,kw OR 'variable mapping':ti,ab,kw OR 'construct mapping':ti,ab,kw OR 'anchor item':ti,ab,kw OR 'anchor items':ti,ab,kw OR 'bridging item':ti,ab,kw OR 'bridging items':ti,ab,kw OR 'bridging study':ti,ab,kw OR 'differential item functioning':ti,ab,kw) AND (survey*:ti,ab,kw OR questionnaire*:ti,ab,kw OR instrument*:ti,ab,kw OR scale*:ti,ab,kw OR cohort*:ti,ab,kw OR 'population health':ti,ab,kw OR 'health status':ti,ab,kw OR 'patient-reported outcome':ti,ab,kw OR 'patient-reported outcomes':ti,ab,kw OR 'patient-reported experience measure':ti,ab,kw OR 'patient-reported experience measures':ti,ab,kw)
```

### Línea C — `SR-EMBASE-C`

Versión de estrategia: 0.2.

Campos: title; abstract; author keywords. Filtros: None.

```text
('harmonization framework':ti,ab,kw OR 'harmonisation framework':ti,ab,kw OR 'harmonization protocol':ti,ab,kw OR 'harmonisation protocol':ti,ab,kw OR 'harmonization workflow':ti,ab,kw OR 'harmonisation workflow':ti,ab,kw OR 'harmonization algorithm':ti,ab,kw OR 'harmonisation algorithm':ti,ab,kw OR 'harmonization pipeline':ti,ab,kw OR 'harmonisation pipeline':ti,ab,kw OR 'harmonization platform':ti,ab,kw OR 'harmonisation platform':ti,ab,kw OR 'common data model':ti,ab,kw OR 'metadata mapping':ti,ab,kw OR 'ontology mapping':ti,ab,kw OR 'schema mapping':ti,ab,kw OR 'data integration framework':ti,ab,kw) AND (survey*:ti,ab,kw OR questionnaire*:ti,ab,kw OR cohort*:ti,ab,kw OR epidemiolog*:ti,ab,kw OR 'population health':ti,ab,kw OR 'patient-reported measure':ti,ab,kw OR 'patient-reported measures':ti,ab,kw OR 'patient reported measure':ti,ab,kw OR 'patient reported measures':ti,ab,kw)
```

## APA PsycINFO — EBSCOhost

La consulta usa `TI`, `AB` y `KW`. Tras acceder, revisar el APA
Thesaurus y añadir encabezamientos `SU` validados como complemento.
No activar expansores de materias sin registrarlo como modificación.

### Línea A — `SR-PSYCINFO-A`

Versión de estrategia: 0.3.

Campos: TI; AB; KW. Filtros: None.

```text
(TI ("data harmonization" OR "data harmonisation" OR "retrospective harmonization" OR "retrospective harmonisation" OR "ex post harmonization" OR "ex-post harmonization" OR "ex post harmonisation" OR "ex-post harmonisation" OR "post hoc harmonization" OR "post hoc harmonisation" OR "pooled data harmonization" OR "pooled data harmonisation" OR "individual-level data harmonization" OR "individual-level data harmonisation" OR "variable harmonization" OR "variable harmonisation" OR "survey harmonization" OR "survey harmonisation" OR "questionnaire harmonization" OR "questionnaire harmonisation" OR "semantic harmonization" OR "semantic harmonisation") OR AB ("data harmonization" OR "data harmonisation" OR "retrospective harmonization" OR "retrospective harmonisation" OR "ex post harmonization" OR "ex-post harmonization" OR "ex post harmonisation" OR "ex-post harmonisation" OR "post hoc harmonization" OR "post hoc harmonisation" OR "pooled data harmonization" OR "pooled data harmonisation" OR "individual-level data harmonization" OR "individual-level data harmonisation" OR "variable harmonization" OR "variable harmonisation" OR "survey harmonization" OR "survey harmonisation" OR "questionnaire harmonization" OR "questionnaire harmonisation" OR "semantic harmonization" OR "semantic harmonisation") OR KW ("data harmonization" OR "data harmonisation" OR "retrospective harmonization" OR "retrospective harmonisation" OR "ex post harmonization" OR "ex-post harmonization" OR "ex post harmonisation" OR "ex-post harmonisation" OR "post hoc harmonization" OR "post hoc harmonisation" OR "pooled data harmonization" OR "pooled data harmonisation" OR "individual-level data harmonization" OR "individual-level data harmonisation" OR "variable harmonization" OR "variable harmonisation" OR "survey harmonization" OR "survey harmonisation" OR "questionnaire harmonization" OR "questionnaire harmonisation" OR "semantic harmonization" OR "semantic harmonisation")) AND (TI (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "health survey" OR "health surveys" OR "patient-reported measure" OR "patient-reported measures" OR "patient reported measure" OR "patient reported measures" OR "cross-national" OR "cross-country" OR multicountry OR "multi-country") OR AB (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "health survey" OR "health surveys" OR "patient-reported measure" OR "patient-reported measures" OR "patient reported measure" OR "patient reported measures" OR "cross-national" OR "cross-country" OR multicountry OR "multi-country") OR KW (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "health survey" OR "health surveys" OR "patient-reported measure" OR "patient-reported measures" OR "patient reported measure" OR "patient reported measures" OR "cross-national" OR "cross-country" OR multicountry OR "multi-country"))
```

### Línea B — `SR-PSYCINFO-B`

Versión de estrategia: 0.3.

Campos: TI; AB; KW. Filtros: None.

```text
(TI ("measurement equivalence" OR "measurement invariance" OR "construct equivalence" OR "conceptual equivalence" OR "semantic equivalence" OR "functional equivalence" OR "item equivalence" OR "question comparability" OR "questionnaire comparability" OR "cross-survey comparability" OR "cross-cultural comparability" OR "common metric" OR "scale linking" OR "score linking" OR "test equating" OR crosswalk* OR "item mapping" OR "variable mapping" OR "construct mapping" OR "anchor item" OR "anchor items" OR "bridging item" OR "bridging items" OR "bridging study" OR "differential item functioning") OR AB ("measurement equivalence" OR "measurement invariance" OR "construct equivalence" OR "conceptual equivalence" OR "semantic equivalence" OR "functional equivalence" OR "item equivalence" OR "question comparability" OR "questionnaire comparability" OR "cross-survey comparability" OR "cross-cultural comparability" OR "common metric" OR "scale linking" OR "score linking" OR "test equating" OR crosswalk* OR "item mapping" OR "variable mapping" OR "construct mapping" OR "anchor item" OR "anchor items" OR "bridging item" OR "bridging items" OR "bridging study" OR "differential item functioning") OR KW ("measurement equivalence" OR "measurement invariance" OR "construct equivalence" OR "conceptual equivalence" OR "semantic equivalence" OR "functional equivalence" OR "item equivalence" OR "question comparability" OR "questionnaire comparability" OR "cross-survey comparability" OR "cross-cultural comparability" OR "common metric" OR "scale linking" OR "score linking" OR "test equating" OR crosswalk* OR "item mapping" OR "variable mapping" OR "construct mapping" OR "anchor item" OR "anchor items" OR "bridging item" OR "bridging items" OR "bridging study" OR "differential item functioning")) AND (TI (survey* OR questionnaire* OR instrument* OR scale* OR cohort* OR "population health" OR "health status" OR "patient-reported outcome" OR "patient-reported outcomes" OR "patient-reported experience measure" OR "patient-reported experience measures") OR AB (survey* OR questionnaire* OR instrument* OR scale* OR cohort* OR "population health" OR "health status" OR "patient-reported outcome" OR "patient-reported outcomes" OR "patient-reported experience measure" OR "patient-reported experience measures") OR KW (survey* OR questionnaire* OR instrument* OR scale* OR cohort* OR "population health" OR "health status" OR "patient-reported outcome" OR "patient-reported outcomes" OR "patient-reported experience measure" OR "patient-reported experience measures"))
```

### Línea C — `SR-PSYCINFO-C`

Versión de estrategia: 0.3.

Campos: TI; AB; KW. Filtros: None.

```text
(TI ("harmonization framework" OR "harmonisation framework" OR "harmonization protocol" OR "harmonisation protocol" OR "harmonization workflow" OR "harmonisation workflow" OR "harmonization algorithm" OR "harmonisation algorithm" OR "harmonization pipeline" OR "harmonisation pipeline" OR "harmonization platform" OR "harmonisation platform" OR "common data model" OR "metadata mapping" OR "ontology mapping" OR "schema mapping" OR "data integration framework") OR AB ("harmonization framework" OR "harmonisation framework" OR "harmonization protocol" OR "harmonisation protocol" OR "harmonization workflow" OR "harmonisation workflow" OR "harmonization algorithm" OR "harmonisation algorithm" OR "harmonization pipeline" OR "harmonisation pipeline" OR "harmonization platform" OR "harmonisation platform" OR "common data model" OR "metadata mapping" OR "ontology mapping" OR "schema mapping" OR "data integration framework") OR KW ("harmonization framework" OR "harmonisation framework" OR "harmonization protocol" OR "harmonisation protocol" OR "harmonization workflow" OR "harmonisation workflow" OR "harmonization algorithm" OR "harmonisation algorithm" OR "harmonization pipeline" OR "harmonisation pipeline" OR "harmonization platform" OR "harmonisation platform" OR "common data model" OR "metadata mapping" OR "ontology mapping" OR "schema mapping" OR "data integration framework")) AND (TI (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "patient-reported measure" OR "patient-reported measures" OR "patient reported measure" OR "patient reported measures") OR AB (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "patient-reported measure" OR "patient-reported measures" OR "patient reported measure" OR "patient reported measures") OR KW (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "patient-reported measure" OR "patient-reported measures" OR "patient reported measure" OR "patient reported measures"))
```

## Web of Science Core Collection

### Línea A — `SR-WOS-A`

Versión de estrategia: 0.3.

Campos: Topic. Filtros: Core Collection; indexes to record at execution.

```text
TS=(("data harmonization" OR "data harmonisation" OR "retrospective harmonization" OR "retrospective harmonisation" OR "ex post harmonization" OR "ex-post harmonization" OR "ex post harmonisation" OR "ex-post harmonisation" OR "post hoc harmonization" OR "post hoc harmonisation" OR "pooled data harmonization" OR "pooled data harmonisation" OR "individual-level data harmonization" OR "individual-level data harmonisation" OR "variable harmonization" OR "variable harmonisation" OR "survey harmonization" OR "survey harmonisation" OR "questionnaire harmonization" OR "questionnaire harmonisation" OR "semantic harmonization" OR "semantic harmonisation") AND (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "health survey*" OR "patient-reported measure*" OR "patient reported measure*" OR "cross-national" OR "cross-country" OR multicountry OR "multi-country"))
```

### Línea B — `SR-WOS-B`

Versión de estrategia: 0.3.

Campos: Topic. Filtros: Core Collection; indexes to record at execution.

```text
TS=(("measurement equivalence" OR "measurement invariance" OR "construct equivalence" OR "conceptual equivalence" OR "semantic equivalence" OR "functional equivalence" OR "item equivalence" OR "question comparability" OR "questionnaire comparability" OR "cross-survey comparability" OR "cross-cultural comparability" OR "common metric" OR "scale linking" OR "score linking" OR "test equating" OR crosswalk* OR "item mapping" OR "variable mapping" OR "construct mapping" OR "anchor item*" OR "bridging item*" OR "bridging stud*" OR "differential item functioning") AND (survey* OR questionnaire* OR instrument* OR scale* OR cohort* OR "population health" OR "health status" OR "patient-reported outcome*" OR "patient-reported experience measure*"))
```

### Línea C — `SR-WOS-C`

Versión de estrategia: 0.3.

Campos: Topic. Filtros: Core Collection; indexes to record at execution.

```text
TS=(("harmonization framework" OR "harmonisation framework" OR "harmonization protocol" OR "harmonisation protocol" OR "harmonization workflow" OR "harmonisation workflow" OR "harmonization algorithm" OR "harmonisation algorithm" OR "harmonization pipeline" OR "harmonisation pipeline" OR "harmonization platform" OR "harmonisation platform" OR "common data model" OR "metadata mapping" OR "ontology mapping" OR "schema mapping" OR "data integration framework") AND (survey* OR questionnaire* OR cohort* OR epidemiolog* OR "population health" OR "patient-reported measure*" OR "patient reported measure*"))
```

## Exportación y entrega

1. Exportar cada línea por separado en RIS, incluyendo como mínimo título,
   resumen, autores, año, revista, DOI, PMID, palabras clave, descriptores y
   el identificador propio de la base. En Web of Science seleccionar Core
   Collection y `Full Record and Cited References` cuando esté disponible.
   En EBSCOhost verificar que la base seleccionada sea solo APA PsycINFO.
2. Usar los nombres y rutas predefinidos en
   `research/scoping-review/manifests/manual-exports.csv`.
3. Si hay varios lotes, añadir filas con sufijos `B002`, `B003`, etc., sin
   combinar ni editar las exportaciones originales.
4. Completar fecha, total comunicado, indicador de completitud, índices de
   Web of Science e incidencias. Cambiar a `READY` solo cuando el archivo
   correspondiente esté en su ruta.
5. Ejecutar:

```powershell
Rscript --vanilla scripts/26_import_manual_scoping_exports.R
Rscript --vanilla scripts/27_build_scoping_corpus.R
Rscript --vanilla scripts/28_validate_scoping_seeds.R
Rscript --vanilla scripts/29_build_scoping_prisma.R
Rscript --vanilla scripts/30_prepare_scoping_search_pilot.R
```

Los RIS se consideran respuestas brutas inmutables y quedan excluidos de
Git. Durante la importación se registran SHA-256, número de filas y fecha.
El pipeline conserva base, línea, estrategia, lote, archivo e identificador
original antes de deduplicar.
