# Protocolo de revisión narrativa metodológica

**Título:** Métodos para la armonización retrospectiva aplicables a PaRIS
Cycle 1 y EHIS Wave 3<br>
**Versión:** 0.1<br>
**Fecha:** 2026-08-20<br>
**Tipo:** revisión narrativa orientada al desarrollo metodológico del proyecto

## Propósito

Identificar, organizar y sintetizar métodos que permitan diseñar, ejecutar y
validar la armonización retrospectiva entre PaRIS Cycle 1 y EHIS Wave 3. La
revisión no pretende estimar un efecto ni identificar exhaustivamente toda la
literatura. Su producto principal será un conjunto razonado de decisiones para
el modelo de metadatos, la taxonomía de armonizabilidad, los algoritmos y la
validación del proyecto.

## Pregunta orientadora

¿Qué principios, procedimientos y métodos empíricos son adecuados para evaluar
y ejecutar una armonización retrospectiva transparente entre dos encuestas de
salud que difieren en finalidad, población, instrumentos, periodo y diseño?

## Ejes de interés

1. Definición independiente de conceptos y variables objetivo.
2. Compatibilidad de concepto, medida, universo, tiempo, representación,
   derivación y administración.
3. Armonización de variables categóricas, continuas, escalas y PROMs/PREMs.
4. Comparabilidad transcultural y entre modos de administración.
5. Comparabilidad de poblaciones, diseños muestrales y ponderaciones.
6. Validación conceptual, revisión humana, concordancia y validación empírica.
7. Metadatos, procedencia, versionado, FAIR y automatización asistida.
8. Particularidades documentadas de PaRIS Cycle 1 y EHIS Wave 3.

## Fuentes

- PubMed/MEDLINE mediante NCBI E-utilities, de forma reproducible en R.
- Búsqueda dirigida en OECD, Eurostat, DDI Alliance y Maelstrom Research.
- Rastreo de referencias y citas de documentos nucleares.
- Scopus y Web of Science solo si existe acceso institucional; sus consultas se
  documentarán aunque su ejecución y exportación sean manuales.

## Estrategia

Se combinarán tres búsquedas: métodos generales de armonización retrospectiva,
equivalencia de medidas/cuestionarios y documentos o aplicaciones directamente
relacionados con PaRIS o EHIS. No se impondrá inicialmente límite de fecha. Se
incluirán publicaciones en inglés o español y documentación institucional en
otros idiomas cuando sea esencial y evaluable.

Las consultas exactas se conservan en `search-strategies.csv`. El script
`scripts/04_search_narrative_review.R` registra la fecha, recupera los
resultados de PubMed, normaliza los metadatos y deduplica por PMID y DOI.

## Selección pragmática

Se priorizarán documentos que aporten al menos uno de estos elementos:

- un marco explícito o flujo reproducible de armonización;
- criterios para establecer equivalencia o incompatibilidad;
- definición y generación de variables objetivo;
- métodos para enlazar escalas o constructos latentes;
- procedimientos de validación o sensibilidad;
- modelos de metadatos o procedencia;
- información primaria sobre diseño y comparabilidad de PaRIS o EHIS.

Se descartarán usos incidentales del término *harmonization*, armonización
prospectiva sin aprendizaje transferible, integración puramente técnica sin
semántica y estudios clínicos sin relación metodológica con encuestas o medidas
reportadas por pacientes.

La selección será intencional, iterativa y saturada por temas, no basada en un
diagrama PRISMA. `reviewed-screening.csv` conserva los metadatos y la propuesta
de clasificación asistida; `screening.csv` es el registro canónico y separa
esas propuestas de la decisión, fecha e identidad del investigador. Ninguna
celda vacía en los campos de confirmación se interpretará como aceptación.
La interfaz autocontenida `screening-review.html` facilita esta revisión,
conserva el progreso localmente y permite actualizar el registro canónico con
autorización explícita del navegador o exportar una copia de respaldo. Tras la
primera selección, la interfaz conserva el acceso al archivo para las
actualizaciones posteriores mientras el navegador mantenga el permiso.

## Extracción y síntesis

Para cada fuente nuclear se recogerán: diseño, fuentes armonizadas, unidad,
tipo de variables, modelo conceptual, definición del objetivo, dimensiones de
compatibilidad, algoritmo, missingness, validación, sensibilidad, software,
procedencia, limitaciones y consecuencia concreta para PaRIS–EHIS.

La síntesis será temática. Cada conclusión se etiquetará como:

- `ADOPT`: incorporar al protocolo o infraestructura;
- `ADAPT`: incorporar con modificaciones;
- `CONSIDER`: evaluar durante el piloto;
- `REJECT`: no aplicable, indicando el motivo.

## Criterio de suficiencia

La búsqueda se considerará suficiente cuando cada eje cuente con al menos una
fuente metodológica sólida, los documentos oficiales esenciales de ambas
encuestas estén representados y nuevas búsquedas o rastreos no cambien las
decisiones principales del framework. La búsqueda se actualizará antes de
cerrar el protocolo 1.0 o de redactar el manuscrito metodológico.

## Límites previstos

Al ser narrativa, la selección incorpora juicio del equipo y no permite afirmar
exhaustividad. PubMed no cubre toda la literatura de ciencias sociales y
metadatos. Estas limitaciones se compensarán documentando las consultas,
incluyendo fuentes institucionales y realizando rastreo dirigido.
