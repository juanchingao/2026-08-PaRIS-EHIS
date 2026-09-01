# Protocolo de la scoping review metodológica

**Work Package histórico:** WP1, reclasificado como WP1A
**Versión:** 0.2  
**Fecha:** 2026-08-25  
**Estado:** `UNDER_REVISION` — pregunta de investigación y estrategia en redefinición; pendiente de aprobación, registro y revisión PRESS
**Guías:** JBI Manual for Evidence Synthesis, PRISMA-ScR y PRISMA-S

## Título

**Métodos, criterios y procedimientos para evaluar la armonizabilidad
retrospectiva entre encuestas e instrumentos de salud: protocolo de una
scoping review**

## Justificación

La literatura relevante está dispersa entre epidemiología, metodología de
encuestas, psicometría, ciencias sociales e infraestructuras de datos. Una
búsqueda limitada a la palabra *harmonization* perdería métodos descritos como
equivalencia de medida, linking, equating, crosswalk, mapeo o comparabilidad.
Por otra parte, identificar que varios estudios han combinado datos no permite
saber si evaluaron la equivalencia ni si documentaron transformaciones
transferibles.

La revisión debe alimentar un procedimiento operativo para decidir si una
variable o constructo puede armonizarse, con qué pérdida de información, bajo
qué supuestos y con qué evidencia de comparabilidad. EHIS y OECD PaRIS son el
primer caso de aplicación, pero no restringen la revisión metodológica. Los
métodos podrán evaluarse posteriormente en HRS, SHARE, ELSA, CCHS, BRFSS, MEPS,
EU-SILC u otras fuentes justificadas.

Una scoping review es adecuada porque se pretende mapear conceptos, métodos,
criterios, infraestructuras y lagunas, no estimar un efecto común. El corpus
narrativo anterior se conserva como piloto y fuente de referencias semilla; no
se considerará una ejecución definitiva de este protocolo.

## Pregunta principal

> **Estado al 2026-09-01:** formulación de trabajo, no congelada. JALR y la
> segunda investigadora revisarán su alcance antes de traducirla a una nueva
> estrategia. Las ejecuciones v0.2 de PubMed y Scopus se conservan como pruebas
> metodológicas y no constituyen la búsqueda definitiva de WP1.

> ¿Qué métodos, criterios y procedimientos se han utilizado para determinar si
> variables o constructos de distintas encuestas, cohortes o instrumentos de
> salud pueden armonizarse retrospectivamente, cómo se documenta esa decisión y
> cómo se valida la comparabilidad resultante?

## Objetivos

1. Identificar marcos, procedimientos y aplicaciones transferibles para
   evaluar armonizabilidad retrospectiva.
2. Describir cómo se definen constructos, DataSchemas, common data models y
   variables objetivo antes de asignar variables fuente.
3. Mapear criterios de equivalencia conceptual, semántica, funcional, de
   población y contexto, temporal, de formulación, representación y
   administración.
4. Catalogar transformaciones, unidades, escalas, ventanas temporales,
   missingness, anclajes, linking, equating y crosswalks.
5. Describir cómo se clasifica una variable como armonizable, parcialmente
   armonizable o no armonizable y cómo se representa la incertidumbre y la
   pérdida de información.
6. Examinar la validación psicométrica, distributiva, nomológica, empírica y de
   transportabilidad, incluidas sus condiciones de aplicabilidad.
7. Identificar requisitos de trazabilidad: procedencia, versiones, algoritmos,
   decisiones, software, código y productos reutilizables.
8. Proponer requisitos mínimos de evaluación y documentación para el framework
   PaRIS–EHIS y sus extensiones.

## Criterios PCC

### Participantes o fuentes de datos

Encuestas poblacionales o de servicios sanitarios, cohortes, estudios
observacionales e instrumentos con variables de salud, atención sanitaria,
PROMs o PREMs. No se restringirá por edad, país o condición clínica cuando el
método sea transferible a encuestas de salud.

### Concepto

Evaluación o ejecución documentada de armonización retrospectiva,
comparabilidad entre encuestas, equivalencia conceptual o de medida,
construcción de variables comunes, mapeo, transformación, linking/equating,
crosswalks o evaluación del impacto de diferencias de población, tiempo,
diseño, contexto o modo.

### Contexto

Cualquier país, sistema sanitario o entorno analítico. Se incluirán trabajos
metodológicos, aplicaciones empíricas suficientemente documentadas,
infraestructuras y documentos técnicos pertinentes.

## Tipos de evidencia elegible

1. Estudios metodológicos.
2. Aplicaciones empíricas que describan suficientemente el procedimiento.
3. Infraestructuras, frameworks o common data models con decisiones
   transferibles documentadas.
4. Protocolos, manuales, codebooks, diccionarios, informes técnicos o software
   vinculado a una iniciativa identificable.

## Criterios de inclusión

La fuente debe aportar al menos uno de los siguientes elementos:

1. armonización retrospectiva entre dos o más encuestas, estudios, cohortes o
   instrumentos;
2. evaluación de equivalencia conceptual, semántica, funcional o de medida;
3. linking, equating, crosswalk, anclaje o transformación de escalas entre
   fuentes;
4. mapeo de variables, ítems o constructos a un DataSchema o common data model;
5. criterios o clasificación explícita de armonizabilidad;
6. evaluación del efecto de población, contexto, periodo, diseño, modo,
   formulación u opciones de respuesta sobre la comparabilidad;
7. validación empírica o psicométrica de variables armonizadas;
8. documentación, trazabilidad, control de versiones o infraestructura con un
   proceso de armonización transferible a encuestas de salud.

No se exigirá que el título o resumen contenga *harmonization*. No se impondrá
inicialmente límite de fecha, idioma ni tipo de publicación. La ausencia de
resumen no será motivo de exclusión.

## Criterios de exclusión

1. Normalización meramente técnica de formato o terminología sin evaluación
   conceptual.
2. Armonización de imagen, ómicas, señales o laboratorio sin método transferible
   a encuestas de salud.
3. Integración de historias clínicas sin componente metodológico transferible.
4. Estudios que solo apilen, agrupen o analicen conjuntamente bases sin
   describir decisiones, criterios o transformaciones.
5. Uso de una variable previamente armonizada sin explicar el procedimiento.
6. Mención incidental de una plataforma o infraestructura sin información
   metodológica.
7. Comparaciones agregadas sin aportación a la evaluación de comparabilidad.
8. Psicometría general sin conexión defendible con armonización retrospectiva
   entre encuestas o instrumentos.
9. Armonización prospectiva sin aprendizaje explícitamente transferible.

Los registros inciertos se mantendrán hasta revisar el texto completo. Los
motivos de exclusión a texto completo se registrarán con vocabulario controlado.

## Fuentes de información

### Bases bibliográficas principales

- MEDLINE mediante PubMed;
- Scopus;
- Embase mediante exportación manual de Embase.com si existe acceso; la API no
  está disponible por falta de token institucional;
- APA PsycINFO mediante EBSCOhost, pendiente de localizar el acceso y traducir
  las tres líneas desde el borrador Ovid conservado;
- Web of Science Core Collection mediante Starter API. Las traducciones
  `TI`/`AB` y los pilotos `TS` se registran por separado; la menor riqueza de
  metadatos de Starter se documenta sin imputar campos ausentes.

CINAHL, Sociological Abstracts, EconLit, IEEE Xplore y ACM Digital Library se
considerarán únicamente tras el pilotaje si muestran una contribución
incremental plausible que no cubran las cinco fuentes principales.

### Literatura gris predefinida

Maelstrom Research/DataSHaPER, Gateway to Global Aging Data, CLOSER,
DataSHIELD, OMOP/OHDSI, OECD PaRIS, Eurostat EHIS, WHO, HRS, SHARE, ELSA,
CHARLS, Statistics Canada/CCHS, CDC/BRFSS, AHRQ/MEPS y Eurostat EU-SILC. OSF,
Zenodo y GitHub se usarán solo para productos vinculados a iniciativas
identificables.

La búsqueda dirigida se mantendrá separada de las bases bibliográficas. Por
sitio se registrarán URL, fecha, términos o ruta de navegación, páginas o
resultados revisados, criterio de detención y documentos recuperados.

## Arquitectura de búsqueda

Se ejecutarán por separado tres líneas; se unirán solo después de la descarga:

- **A — armonización retrospectiva explícita:** variantes de armonización de
  datos, variables, encuestas y cuestionarios combinadas con encuestas,
  cohortes, epidemiología, salud poblacional, PROMs/PREMs y contexto
  internacional.
- **B — comparabilidad de constructos y medidas:** equivalencia conceptual y de
  medida, invariancia, DIF, comparabilidad, common metric, linking, equating,
  crosswalks, mapeo y anclajes combinados con encuestas, instrumentos, escalas,
  cohortes y salud.
- **C — marcos e infraestructuras operativas:** framework, protocolo, workflow,
  algoritmo, pipeline o plataforma de armonización, common data model y mapeo
  de metadatos, ontologías o esquemas combinados con encuestas, cohortes,
  epidemiología y salud.

Las líneas A, B y C **no se combinarán entre sí mediante `AND`**. Cada
estrategia tendrá identificador, versión, ecuación exacta, campos, vocabulario
controlado, filtros, fecha, endpoint o plataforma, paginación, totales,
incidencias, archivo bruto y checksum. No se usarán filtros de fecha, idioma,
humanos o tipo documental antes del pilotaje salvo justificación prospectiva.

PubMed combinará texto libre de título/resumen con MeSH verificado. Una eventual
ejecución manual de Embase combinará texto libre con Emtree solo después de
comprobar los descriptores en la plataforma autorizada. PsycINFO mantendrá
términos libres y descriptores del APA Thesaurus traducidos específicamente a
EBSCOhost; Web of Science compara `TI`/`AB` con `TS=` sin tratarlos como campos
equivalentes. No
se copiará sintaxis entre bases.

## Validación y estados

Las estrategias usarán exclusivamente estos estados:

`DRAFT`, `SYNTAX_CHECKED`, `API_TESTED`, `PILOTED`, `SEED_VALIDATED`,
`PRESS_REVIEWED` y `FINAL`.

Una estrategia no avanzará por sintaxis solamente. Se comprobará un conjunto
versionado de referencias semilla que cubra armonización retrospectiva,
equivalencia conceptual y de medida, linking, crosswalks, anclajes, frameworks,
infraestructuras, common data models y aplicaciones en encuestas de salud. La
recuperación se registrará por referencia, base y línea, incluido el término
que la recupera o la razón de ausencia. `SEED_VALIDATED` requiere una prueba
real en la base correspondiente.

La estrategia principal será revisada con PRESS por una persona especialista en
información. PRISMA-S guiará el registro y reporte, no el diseño de la ecuación.

## Pilotaje

Se revisará una muestra estratificada por base y línea para estimar ruido
aparente, cobertura de dominios y contribución incremental. No se eliminarán
términos si ello sacrifica referencias semilla o métodos relevantes. Toda
modificación conservará versión, motivo, fecha y efecto observado.

## Gestión de registros y deduplicación

Las respuestas originales se almacenarán de forma inmutable en `data/raw`; los
metadatos normalizados en `data/interim`; las obras únicas y vínculos en
`data/processed`; los eventos en `logs`; y los informes reproducibles en
`outputs`. Los archivos restringidos o regenerables permanecerán fuera de Git;
se versionarán manifiestos, checksums y código.

El esquema común conservará base, identificador original, línea, estrategia,
versión, fecha, título, resumen, autores, año, revista, DOI, PMID, EID de Scopus,
ID de Embase, palabras clave, términos controlados, tipo documental, idioma y
archivo bruto.

La deduplicación será conservadora y escalonada: DOI normalizado, PMID,
identificadores cruzados proporcionados por las bases, título normalizado y año,
y por último coincidencias aproximadas marcadas para revisión. Se mantendrán
tablas separadas de obras, registros originales, vínculos muchos-a-muchos y
decisiones. Ninguna coincidencia aproximada se fusionará automáticamente.

## Selección

Dos investigadores realizarán independientemente calibración, título/resumen y
texto completo. Las decisiones previas de JALR se conservarán como históricas y
permanecerán ocultas al segundo revisor. Los desacuerdos se resolverán mediante
discusión y adjudicación. Ningún método automático realizará exclusiones
definitivas.

## Extracción o charting

Se recogerán iniciativa, objetivo, fuentes, población, países, dominios,
constructos, temporalidad, marco, unidad de armonización, DataSchema, criterios
de equivalencia, variables fuente, transformaciones, missingness, alineación
poblacional, diseño muestral, validación, incertidumbre, pérdida de información,
transportabilidad, software, código, productos, licencias, limitaciones y
lecciones transferibles. La plantilla se pilotará por dos personas y se
versionará.

## Rastreo de citas

Para cada fuente metodológica nuclear se registrarán referencias hacia atrás,
citas hacia delante, autores, grupos, infraestructuras, artículos relacionados y
revisiones previas. Scopus y, si está disponible, Web of Science se usarán para
citas hacia delante. Cada registro adicional conservará el estudio semilla y el
método que lo originó.

## Evaluación crítica y síntesis

No se excluirán fuentes únicamente por una puntuación de calidad. Se evaluarán
transparencia, reproducibilidad, trazabilidad, adecuación de supuestos,
validación y acceso a productos. Se elaborarán matrices de método–tipo de
variable, criterio–decisión y validación–uso, además de una síntesis descriptiva
y de contenido. No se realizará metaanálisis por defecto.

## Reporte, registro y enmiendas

El informe seguirá PRISMA-ScR y las búsquedas se documentarán con PRISMA-S. El
protocolo se fechará, congelará y registrará en una plataforma elegida por JALR
antes de declarar estrategias `FINAL`. Toda enmienda indicará fecha, motivo,
alcance y momento respecto de la consulta de resultados.

## Roles

JALR aprobará el protocolo y actuará como investigador 1. El investigador 2
realizará cribado y charting independiente. Una persona especialista en
información realizará o supervisará PRESS. Las automatizaciones solo apoyarán
priorización o comprobaciones reproducibles y se evaluarán contra consenso
humano.

## Estado al 25 de agosto de 2026

El corpus histórico contiene búsquedas piloto y 1.076 registros efectivos con
decisiones JALR. Las integraciones se han auditado: PubMed E-utilities responde;
Scopus permite conteo y búsqueda por desplazamiento, pero no abstracts ni cursor
con la autorización actual; Embase reconoce la solicitud pero deniega el recurso
por permisos. PsycINFO y Web of Science no tienen API configurada. Estos hechos
no constituyen todavía ejecuciones finales del WP1.
