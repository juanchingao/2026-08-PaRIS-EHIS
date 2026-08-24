# Protocolo de investigación

> **Versión histórica, sustituida el 24 de agosto de 2026.** El informe OECD
> 2026 (DOI `10.1787/acf46da9-en`) ya ejecuta la comparación general que
> justificaba este alcance. El trabajo activo se define en
> `documentation/protocol/protocol.md`; esta versión se conserva para
> trazabilidad y no debe guiar nuevos análisis.

## Título provisional

**Armonización retrospectiva de las encuestas PaRIS y European Health
Interview Survey (EHIS): desarrollo y validación de un modelo común de
conceptos, medidas y variables para el análisis comparativo de resultados de
salud y atención sanitaria**

**Acrónimo:** PaRISEHIS Harmonisation Project<br>
**Versión:** 0.1<br>
**Estado:** borrador conceptual inicial

## Pregunta principal

¿En qué medida es posible armonizar retrospectivamente las variables de PaRIS
Cycle 1 y EHIS Wave 3 mediante un modelo común de conceptos, medidas,
poblaciones y representaciones que permita análisis comparativos válidos?

## Justificación

La similitud entre nombres o preguntas no garantiza intercambiabilidad. Las
diferencias de población, formulación, referencia temporal, instrumento,
respuesta, derivación, administración y diseño muestral pueden impedir la
comparación. El proyecto adopta una perspectiva inspirada en DDI, ISO/IEC 11179
y Maelstrom: primero se define la variable objetivo; después se evalúa si cada
estudio puede generarla y bajo qué condiciones.

## Objetivo general

Desarrollar, documentar y validar un marco reproducible que identifique qué
información de ambas encuestas puede utilizarse comparativamente, qué
transformaciones requiere y qué limitaciones permanecen.

## Hipótesis

Existirá un subconjunto armonizable, especialmente en sociodemografía,
condiciones crónicas, salud general y utilización. La comparabilidad será menor
en PROMs/PREMs complejos. Un modelo multidimensional detectará incompatibilidades
que la similitud textual no identifica. Aproximar la población EHIS a PaRIS
mejorará algunas comparaciones sin eliminar diferencias de diseño.

## Diseño

Estudio metodológico de armonización retrospectiva seguido de validación
empírica:

- **A. Armonización semántica y metodológica:** fuentes, metadatos, modelo,
  mappings, variables objetivo y algoritmos.
- **B. Evaluación empírica:** aplicación, calidad, comportamiento, ponderación,
  comparabilidad poblacional y sensibilidad.

La semejanza distributiva no sustituye a la compatibilidad conceptual.

## Fuentes y unidades

- PaRIS Cycle 1: cuestionario, codebook, diccionario, metodología y PUF
  autorizados, principalmente 2023–2024.
- EHIS Wave 3: manual, cuestionario modelo, variables de transmisión,
  implementaciones nacionales y microdatos autorizados, principalmente 2019.
- Unidad primaria: individuo. Otros niveles: dominio, concepto, medida, ítem,
  variable fuente, variable objetivo y país-encuesta-ola.

## Modelo y clasificación

`DOMAIN -> CONCEPT -> MEASURE -> SOURCE VARIABLE -> ASSESSMENT -> TARGET
VARIABLE -> ALGORITHM -> HARMONISED VARIABLE`

El assessment separa concepto, medida, universo, tiempo, representación,
derivación y administración. Clases: `DIRECT`, `RECODABLE`, `DERIVABLE`,
`PARTIAL`, `RELATED`, `NONE`. Estado independiente: `PROPOSED`, `REVIEWED`,
`VALIDATED`, `REJECTED`, `UNRESOLVED`.

## Procedimiento

1. Inventariar y normalizar metadatos.
2. Construir el catálogo conceptual.
3. Definir variables objetivo independientemente de las fuentes.
4. Evaluar cada relación source-to-target.
5. Implementar algoritmos independientes para PaRIS y EHIS.
6. Generar variables armonizadas y ejecutar controles de calidad.
7. Revisar mappings mediante contenido, doble revisión y consenso documentado.
8. Validar empíricamente sin confundir equivalencia con distribución similar.
9. Analizar sensibilidad a puntos de corte, categorías, missingness, países y
   restricciones poblacionales.

## Comparabilidad poblacional

Se evaluarán poblaciones originales, restricción por edad, aproximación al
contacto con atención primaria y máxima población común reproducible. Se
documentarán edad, residencia, utilización, cronicidad, país y periodo. La
compatibilidad poblacional será gradual, no dicotómica.

## Diseño muestral y ausencia

Los análisis incorporarán pesos, estratos, conglomerados y procedimientos de
varianza disponibles. La ponderación se mantiene separada de la armonización.
Se distinguirán ausencia estructural, no aplicable, omisión, rechazo,
desconocido, no recogido y no disponible.

## Automatización

Búsqueda léxica, similitud semántica, embeddings y modelos de lenguaje pueden
generar candidatos, nunca validarlos por sí solos. Su rendimiento se evaluará
contra mappings revisados mediante precision, recall, ranking y top-k accuracy.

## Reproducibilidad, ética y productos

Los originales son inmutables y los microdatos no se almacenan en Git. Toda
salida se vincula a versiones de datos, mapping, algoritmo, parámetros y
commit. Se revisarán licencia, almacenamiento, disclosure y ética. Se producirán
catálogos, modelo común, mappings, variables objetivo, algoritmos, datos
armonizados autorizados, validación y documentación de incompatibilidades.

## Pendientes para versión 1.0

- Inventario real de variables.
- Definición formal de población PaRIS y diseño muestral disponible.
- Primera ontología de dominios y conceptos.
- Piloto con variables seleccionadas.
- Criterios operativos detallados de clases de armonización.
- Plan estadístico de validación empírica.

## Referencias iniciales

- Fortier I, Raina P, van den Heuvel ER, et al. Maelstrom Research guidelines
  for rigorous retrospective data harmonization. *International Journal of
  Epidemiology*. 2017;46(1):103–115.
- Data Documentation Initiative, Lifecycle 3.3.
- Eurostat, EHIS Wave 3 methodological manual y documentación asociada.
- OECD, PaRIS Cycle 1 questionnaire, codebook, data dictionary y metodología.
