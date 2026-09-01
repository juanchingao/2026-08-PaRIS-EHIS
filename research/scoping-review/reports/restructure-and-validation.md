# Reestructuración y validación de WP1

**Fecha:** 2026-09-01  
**Estado:** ejecución WoS WP1A completa; validación científica pendiente

## Estado inicial preservado

| Fuente | Estado encontrado | Resultados |
|---|---|---:|
| PubMed v0.3 | ejecutada completamente | A 2.109; B 87.716; C 695 |
| Scopus v0.2 | ejecutada completamente | A 674; B 16.430; C 683 |
| Embase | prueba HTTP 403; ejecución manual pendiente | 0 |
| PsycINFO | sintaxis preparada; acceso pendiente | 0 |
| WoS | Starter autenticado; estrategias antiguas no ejecutadas | 0 |

Los resultados y consultas históricos no se alteraron. El corpus anterior se
clasifica como WP1A mediante aliases externos.

## Pilotos WoS Starter

| Estrategia | Campo | Total | Decisión |
|---|---|---:|---|
| WP1A-WOS-01 | TI/AB | 532 | ejecutada completamente |
| WP1A-WOS-01-TS | TS | 723 | piloto; no sustituye TI/AB |
| WP1A-WOS-02 | TI/AB | 3.660 | ejecutada completamente |
| WP1A-WOS-02-TS | TS | 5.464 | piloto; no sustituye TI/AB |
| WP1A-WOS-V2-PILOT | TS | 55.493 | `REQUIRES_REVIEW`; ruido excesivo |
| WP1B-WOS-01 | TS | 177.167 | demasiado amplia; rediseñar |
| WP1B-FUTURE-WOS-01 | TS | 2.526 | refinar antes de ejecutar |

La ampliación de `TI/AB` a `TS` elevó los recuentos un 35,9 % en WP1A-01 y un
49,3 % en WP1A-02. `TS` incluye campos de palabras clave, de modo que la
diferencia no se interpreta como mayor sensibilidad validada.

## Muestras por relevancia y fecha

Se guardaron fuera de Git 10 registros por estrategia y orden para revisión
humana en `outputs/tables/scoping-review/wos-validation-samples.csv`.

- WP1A-01 por relevancia recupera la revisión estadística de 2026, el protocolo
  de definición de armonización y las guías Maelstrom; por fecha aparece ruido
  clínico, NLP y laboratorio.
- WP1A-02 por relevancia recupera PROMIS, el glosario de equivalencia y common
  metrics; por fecha domina la validación psicométrica aislada, fuente prevista
  de ruido.
- WP1B general muestra ruido muy alto e incluso documentos ajenos a salud. No
  es apta para ejecución masiva.
- WP1B-FUTURE distingue constructos pertinentes en relevancia, pero la muestra
  reciente mezcla aplicaciones clínicas, conducta sostenible y contextos no
  transferibles. Necesita bloques de tipo de evidencia y contexto más fuertes.

Estas observaciones son una auditoría inicial, no una estimación formal de
precisión. La columna de relevancia humana permanece pendiente.

## Centinelas

Cuatro de seis referencias candidatas se recuperaron por DOI en las ejecuciones
fieles. BioSHaRE y el informe OECD no se recuperaron. OECD puede requerir el
registro de literatura oficial; la ausencia de BioSHaRE exige revisar la
estrategia antes de afirmar sensibilidad adecuada. El conjunto completo sigue
pendiente de validación humana.

## Limitaciones de Starter

La integración utilizada es Web of Science Starter API, endpoint
`/apis/wos-starter/v1/documents`, autenticado mediante `X-ApiKey`. En esta
licencia se obtuvieron UT, DOI/PMID cuando existen, título, autores, fuente,
año, tipo documental, author keywords y citas cuando están disponibles. No se
recibieron abstracts, afiliaciones, Keywords Plus ni financiación. Starter
admite 50 registros por página; el cliente usa paginación, backoff, checkpoints
y deduplicación por UT. La documentación pública enumera `TI` y `TS`, pero no
`AB`; aunque la API aceptó las consultas `AB` y devolvió resultados paginables,
debe confirmarse con Clarivate que su interpretación corresponde realmente al
campo Abstract antes de considerar validada la fidelidad de la traducción.

## Recomendación de reejecución

No repetir todavía PubMed, Scopus ni Embase con WP1A v2.0. Sus 55.493 resultados
piloto WoS indican una modificación material y una pérdida probable de
precisión. Primero deben revisarse los términos por línea, asegurar la
recuperación de BioSHaRE, completar la evaluación humana de muestras y realizar
PRESS. Si se aprueba, será una estrategia v2.0 y sus resultados permanecerán
separados de v0.2/v0.3.

WP1B y WP1B-FUTURE quedan diseñadas y pilotadas, no ejecutadas. Deben dividirse
por familias de evidencia y reforzar filtros de revisión/framework/consenso sin
convertirse en inventarios indiscriminados de instrumentos.
