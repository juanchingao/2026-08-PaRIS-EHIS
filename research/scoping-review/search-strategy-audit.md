# Auditoría de la búsqueda bibliográfica de WP1

**Versión:** 0.2  
**Fecha de cierre técnico:** 2026-08-25  
**Objeto:** corpus histórico, estrategias A/B/C, integraciones y ejecuciones de
PubMed, Scopus y Embase.

## Diagnóstico inicial

La búsqueda narrativa anterior era útil como piloto y fuente de referencias
semilla, pero no respondía de forma reproducible a la pregunta de la scoping
review. Sus consultas mezclaban objetivos distintos, aplicaban topes de 300
registros en PubMed y 1.000 en Scopus, y no cubrían de forma suficiente
equivalencia, linking, equating, crosswalks, anclajes, common data models ni
trazabilidad de las decisiones. Sus criterios tampoco pueden trasladarse sin
revisión porque fueron formulados para otra pregunta.

Los resultados históricos se conservan intactos en `../narrative-review/` y no
se presentan como identificación definitiva de WP1.

## Reformulación implementada

La versión 0.2 separa tres líneas que nunca se combinan entre sí mediante
`AND`:

- **A:** armonización retrospectiva explícita;
- **B:** comparabilidad de constructos y medidas;
- **C:** marcos e infraestructuras operativas.

Cada línea combina únicamente su bloque metodológico con un bloque de encuestas,
cohortes, instrumentos o salud poblacional. No se aplicaron filtros de fecha,
idioma, humanos ni tipo documental. Las ecuaciones canónicas se conservan en
`strategies/search-strategies-v0.2.csv`; los estados y recuentos se separan en
`strategies/strategy-register.csv`.

## Ejecuciones reales

| Base | Línea A | Línea B | Línea C | Estado |
|---|---:|---:|---:|---|
| PubMed/MEDLINE | 2.109 | 87.716 | 695 | Completa |
| Scopus | 674 | 16.430 | 683 | Completa |
| Embase API | 0 | 0 | 0 | No ejecutada; prueba HTTP 403 |

Los recuentos son registros únicos dentro de cada fuente y línea. No deben
sumarse como si fueran obras únicas. Las tres líneas completas de PubMed y
Scopus recuperaron las doce referencias semilla bibliográficas; el informe OECD
se mantiene como referencia gris y no se esperaba que estuviera indexado. La
validación Embase no pudo realizarse.

PubMed se recuperó mediante ESearch con historial y EFetch paginado. La línea B
se dividió temporalmente para evitar el límite operativo de ESearch: las
particiones generaron 97.799 filas, de las que 10.083 eran PMIDs repetidos entre
particiones; tras colapsarlas quedaron exactamente los 87.716 PMIDs comunicados
por la consulta matriz.

Scopus se ejecutó como unión lógica exacta de 18 subconsultas aceptadas por la
API. La autorización disponible solo admitió 25 registros por página, rechazó
el cursor y no autorizó Abstract Retrieval. El bloque B-SQ01 superó la ventana
de 5.000 y se dividió por año hasta 2028. Los recuentos por subconsulta, consultas
exactas, paginación y checksums se congelan en
`manifests/scopus-subqueries.csv`.

Embase se identificó como Elsevier Embase API —no Ovid—. Las pruebas A/B/C
devolvieron HTTP 403 `AUTHENTICATION_ERROR` por falta de derecho sobre el
recurso. No se afirman ejecución, resultados ni descriptores Emtree validados.
Las exportaciones RIS históricas de Embase.com permanecen separadas.

## Pilotaje y precisión pendiente

La línea B aporta sensibilidad para equivalencia, linking, equating y DIF, pero
produce un corpus muy amplio y probablemente contiene psicometría sin utilidad
para armonización retrospectiva entre fuentes. No se ha estrechado
automáticamente: hacerlo antes del cribado podría perder métodos o referencias
semilla. Se generó una muestra ciega de 150 registros —25 por combinación de
base y línea— para estimar relevancia, cobertura y ruido con criterios WP1.

Las decisiones históricas se usaron solo como indicador exploratorio y no como
estimación de precisión, porque proceden de otra pregunta. Ninguna estrategia se
considera `PRESS_REVIEWED` ni `FINAL`.

## Pendientes metodológicos y de acceso

1. Cribar la muestra piloto con dos revisores y decidir si la línea B requiere
   una revisión versionada.
2. Someter la estrategia principal a PRESS mediante `press-review-form.md`.
3. Localizar el acceso EBSCOhost para PsycINFO y traducir A/B/C; la versión Ovid
   se conserva como antecedente `DRAFT` y no debe ejecutarse allí.
4. Ejecutar Web of Science Core Collection manualmente si la interfaz está
   disponible; la vía API queda cerrada por falta de token institucional.
5. Ejecutar y exportar manualmente A/B/C en Embase.com si existe acceso; la vía
   API queda cerrada y no se dedicarán más recursos a ella.
6. Ejecutar y registrar la literatura gris y el rastreo de citas, manteniéndolos
   fuera de los recuentos bibliográficos principales hasta su incorporación
   explícita.

## Decisión de conservación

No se borran ni renombran las búsquedas anteriores. La versión 0.1 queda como
antecedente auditable; la versión 0.2 es la primera arquitectura A/B/C ejecutada.
`SEED_VALIDATED` significa recuperación real de las semillas en una base, no
revisión PRESS ni aprobación final del investigador.
