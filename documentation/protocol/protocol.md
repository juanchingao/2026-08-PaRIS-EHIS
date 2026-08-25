# Protocolo de investigación v0.3

## Título provisional

**Desarrollo y evaluación de un framework reproducible para la armonización
retrospectiva de PaRIS y otras encuestas internacionales de salud**

**Acrónimo de trabajo:** PaRIS-HARMONISE
**Versión:** 0.3, propuesta de reformulación
**Fecha:** 24 de agosto de 2026
**Estado:** borrador avanzado pendiente de aprobación por JALR
**Encuesta índice:** OECD PaRIS Cycle 1
**Primer comparador:** European Health Interview Survey, Wave 3

## Resumen

PaRIS, EHIS y otras encuestas internacionales recogen resultados percibidos,
experiencias asistenciales, acceso, utilización, funcionamiento, salud mental,
capacidades y determinantes sociales. Sin embargo, difieren en finalidad,
población, marco muestral, modo de administración, formulación, periodos de
referencia y escalas. La coincidencia nominal entre variables no garantiza que
midan lo mismo ni que sus estimaciones sean intercambiables.

Este proyecto metodológico, retrospectivo y multifuente desarrollará y evaluará
un framework reproducible de armonización con PaRIS como encuesta índice. EHIS
será el primer comparador y constituirá el producto mínimo viable. SHARE y la
Commonwealth Fund International Health Policy Survey (IHP) serán ampliaciones
prioritarias sujetas a viabilidad. CCHS, EU-SILC, MEPS, HRS, BRFSS y People's
Voice Survey (PVS) solo se incorporarán para validaciones o extensiones
específicas justificadas.

El trabajo seguirá las Maelstrom Research Guidelines [@fortier2017]. Separará
la definición conceptual del DataSchema, la generación técnica de variables y
la evaluación empírica de su comparabilidad. La scoping review sistemática será
el Work Package 1 (WP1). No se concatenarán indiscriminadamente microdatos ni se
intentará crear de inicio una infraestructura equivalente a Gateway. El producto
público será principalmente documentación, metadatos, código, algoritmos y
resultados agregados compatibles con las licencias.

## 1. Antecedentes y justificación

PaRIS Cycle 1 estudia a personas de 45 o más años con contacto reciente con
atención primaria y recoge PROMs, PREMs, capacidades, condiciones crónicas y
características de las prácticas [@valderas2025; @oecd2026puf]. EHIS Wave 3 es
una encuesta poblacional de personas de 15 o más años residentes en hogares
privados y cubre estado de salud, utilización, determinantes y antecedentes
socioeconómicos [@eurostat2022quality; @eurostat2024metadata]. Estas fuentes
pueden informar preguntas relacionadas, pero observan poblaciones y procesos de
respuesta diferentes.

La armonización retrospectiva exige definir primero las variables objetivo,
evaluar si cada fuente puede generarlas y documentar algoritmos específicos por
estudio. Maelstrom denomina DataSchema al conjunto de variables objetivo y
subraya que el potencial de armonización depende de la pregunta científica y
del grado de precisión requerido [@fortier2017]. Por tanto, una variable puede
ser utilizable para una descripción amplia y no serlo para una comparación
causal, psicométrica o de desempeño.

## 2. Antecedente directo: OECD 2026

El informe *Comparing patient-reported outcome and experience measures in
international health surveys* [@oecd2026comparison] compara PaRIS, EHIS, IHP,
PVS y SHARE. Examina diseño y población, realiza domain mapping, crosswalks a
nivel de ítem, armoniza escalas de respuesta y presenta algunas comparaciones
restringidas y estandarizadas.

El informe concluye que las encuestas son complementarias, no intercambiables;
que el solapamiento significativo es limitado; que los PROMs se alinean sobre
todo entre PaRIS, EHIS y SHARE, mientras que los PREMs se concentran en PaRIS,
IHP y PVS; y que persisten diferencias importantes tras restringir y
estandarizar poblaciones. La redacción, los anclajes, el periodo, el modo y la
selección poblacional pueden modificar las estimaciones.

En consecuencia, no son novedosos por sí solos un crosswalk PaRIS–EHIS ni una
comparación descriptiva de cuestionarios. El informe OECD se tratará como:

1. antecedente directo que delimita la novedad;
2. fuente de candidatos para el DataSchema;
3. benchmark externo para el piloto PaRIS–EHIS;
4. caso de uso para estudiar reproducibilidad y sensibilidad;
5. evidencia que no sustituye una evaluación independiente de equivalencia.

## 3. Vacío de conocimiento

Persiste la necesidad de un proceso que conecte de forma auditable:

`pregunta -> constructo -> variable DataSchema -> variable fuente -> assessment
-> algoritmo -> variable armonizada -> evaluación empírica -> uso permitido`

En particular, faltan una implementación reproducible sobre microdatos, un
common data model formal, algoritmos versionados, evaluación explícita del grado
de equivalencia, cuantificación del efecto encuesta, evaluación de
transportabilidad, análisis de sensibilidad y validación distributiva y
nomológica. La evaluación psicométrica solo es pertinente cuando existan
constructos y escalas con anclajes suficientes.

## 4. Preguntas de investigación

### 4.1. Nivel 1: pregunta metodológica principal

¿Qué indicadores de resultados percibidos, experiencia asistencial, acceso,
utilización y capacidades pueden compararse válidamente entre PaRIS y otras
encuestas internacionales de salud, mediante qué transformaciones y con qué
grado de comparabilidad, después de considerar diferencias de población, diseño
muestral, formulación, periodo de referencia, modo de administración, contexto
del cuestionario y escala de respuesta?

### 4.2. Nivel 2: transportabilidad

¿En qué medida las variables que pueden generarse con una definición común
conservan distribuciones y asociaciones comparables entre encuestas, países y
poblaciones después de respetar el diseño de cada fuente y aplicar restricciones
o estandarizaciones defendibles?

### 4.3. Nivel 3: aplicación sustantiva posterior

Cuando la comparabilidad haya sido demostrada, ¿cómo se relacionan acceso,
continuidad, coordinación y atención centrada en la persona con salud percibida,
funcionamiento y automanejo, especialmente en personas con multimorbilidad y
vulnerabilidad socioeconómica?

La tercera pregunta no es un objetivo primario de esta versión. Requerirá una
enmienda prospectiva basada en los resultados metodológicos de los niveles 1 y
2.

## 5. Objetivos

### 5.1. Objetivo general

Desarrollar y evaluar un framework reproducible y escalable para armonizar
retrospectivamente indicadores centrados en las personas entre PaRIS y otras
encuestas internacionales de salud, distinguiendo la posibilidad técnica de
generar una variable de su comparabilidad conceptual y empírica.

### 5.2. Objetivos específicos

1. Mapear sistemáticamente métodos, marcos, algoritmos, criterios y productos
   reutilizables mediante una scoping review.
2. Seleccionar encuestas mediante criterios explícitos de relevancia, población,
   documentación, diseño, acceso, coincidencia temporal/geográfica y viabilidad.
3. Definir un DataSchema por constructos antes de asignar variables fuente.
4. Evaluar de forma independiente y multidimensional el potencial de cada par
   encuesta–variable objetivo.
5. Implementar algoritmos auditables, específicos por fuente, con tratamiento
   explícito de universos, filtros, categorías y tipos de ausencia.
6. Evaluar cobertura, missingness, pérdida de información y calidad de los
   productos armonizados.
7. Cuantificar diferencias residuales entre encuestas tras restricciones y
   estandarizaciones preespecificadas.
8. Examinar transportabilidad mediante distribuciones, prevalencias y
   asociaciones nomológicas estimadas dentro de cada encuesta y país.
9. Evaluar sensibilidad a decisiones de población, codificación, ponderación,
   diseño, modo, periodo y datos ausentes.
10. Determinar para qué usos es válida cada variable armonizada y cuáles deben
    permanecer `INCOMPATIBLE`, `UNAVAILABLE` o `UNRESOLVED`.

## 6. Diseño y organización en Work Packages

Estudio metodológico, retrospectivo y multifuente para desarrollar y evaluar un
common data model. Se organiza en paquetes secuenciales con puertas de decisión:

| WP | Contenido | Producto de salida |
|---|---|---|
| WP1 | Scoping review sistemática | Inventario de métodos, iniciativas y criterios |
| WP2 | Selección e inventario de encuestas | Matriz de viabilidad y fuentes elegibles |
| WP3 | DataSchema y assessment | Variables objetivo y matriz de equivalencia revisada |
| WP4 | Piloto PaRIS–EHIS | Algoritmos y evaluación de comparabilidad inicial |
| WP5 | Transportabilidad | Comparaciones distributivas, nomológicas y sensibilidades |
| WP6 | Ampliación prioritaria | Evaluación prospectiva de SHARE e IHP |
| WP7 | Validación/extensiones | Incorporaciones específicas justificadas |

Una fase no se ampliará por inercia. Cada transición exigirá que la
documentación, acceso y calidad sean suficientes para la pregunta prevista.

## 7. Marco conceptual

### 7.1. Maelstrom Research

Las seis etapas de Maelstrom se implementarán de forma explícita:

1. pregunta, objetivos y protocolo;
2. información y selección de estudios;
3. definición del DataSchema y evaluación del potencial;
4. procesamiento específico por fuente;
5. evaluación de calidad;
6. difusión y preservación.

La armonización será iterativa, pero las definiciones conceptuales no se
adaptarán retrospectivamente para conseguir mejores resultados empíricos.

### 7.2. Tres capas que no deben confundirse

- **Armonización conceptual:** define qué se pretende medir y qué diferencias
  son aceptables para el uso propuesto.
- **Generación técnica:** aplica algoritmos source-specific para crear una
  representación común sin borrar procedencia ni pérdida de información.
- **Comparabilidad empírica:** evalúa si las variables generadas se comportan de
  forma suficientemente comparable para el estimando y la inferencia previstos.

Una variable técnicamente generable puede fracasar en la tercera capa.

## 8. Población objetivo y estimandos

### 8.1. Población objetivo común

La población de interés prioritaria es:

- personas de 45 años o más;
- residentes en hogares privados;
- con al menos una enfermedad crónica;
- con contacto reciente con atención primaria, cuando sea identificable.

Algunas fuentes no permitirán reproducir todos los criterios. No se sustituirá
una característica ausente por un proxy débil sin assessment y análisis de
sensibilidad.

### 8.2. Embudo de poblaciones

Cada fuente conservará estimandos separados para:

1. su población de origen;
2. personas de 45 años o más;
3. población anterior residente en hogares privados, si procede y es
   identificable;
4. población anterior con enfermedad crónica comparable;
5. población anterior con contacto reciente comparable;
6. máxima población común defendible para el indicador.

No se afirmará que una restricción convierte encuestas con marcos distintos en
muestras de la misma población.

### 8.3. Resultados metodológicos coprimarios

1. **Potencial de armonización:** clasificación revisada de cada combinación
   variable DataSchema–encuesta y proporción de variables evaluables por dominio.
2. **Diferencia residual entre encuestas:** contraste de estimaciones
   estandarizadas para cada indicador piloto dentro de la máxima población común
   defendible, con incertidumbre compatible con el diseño.

El primer resultado responde si puede generarse una variable. El segundo
responde si se comporta de manera comparable. No son equivalentes.

## 9. Selección de encuestas

### 9.1. Núcleo inicial

- **PaRIS Cycle 1:** encuesta índice.
- **EHIS Wave 3:** primer comparador y piloto del framework.

### 9.2. Ampliación prioritaria

- **SHARE:** prioritaria para PROMs, funcionamiento, salud mental,
  multimorbilidad y envejecimiento.
- **IHP:** prioritaria para PREMs, acceso, continuidad, coordinación y atención
  primaria.

Su inclusión empírica no se presume; dependerá del inventario de viabilidad.

### 9.3. Validación o extensiones específicas

- CCHS;
- EU-SILC;
- MEPS;
- HRS;
- BRFSS;
- PVS.

Estas fuentes no formarán automáticamente parte del análisis primario. Cada una
deberá aportar un dominio, contraste metodológico o validación externa que no
pueda resolverse adecuadamente con el núcleo.

### 9.4. Criterios de inclusión de una encuesta

1. relevancia para uno o más dominios objetivo;
2. población y cobertura geográfica adecuadas a la pregunta;
3. acceso legal y técnico a microdatos o a un entorno analítico suficiente;
4. cuestionario, diccionario y documentación metodológica disponibles;
5. pesos y variables de diseño muestral identificables;
6. países, periodos o poblaciones coincidentes cuando el estimando lo requiera;
7. viabilidad de procesamiento y disclosure;
8. existencia de armonizaciones previas auditables;
9. ganancia científica proporcional al coste y complejidad añadidos.

## 10. Work Package 1: scoping review sistemática

WP1 responderá: ¿qué métodos, criterios y procedimientos se han utilizado para
determinar si variables o constructos de distintas encuestas, cohortes o
instrumentos de salud pueden armonizarse retrospectivamente, cómo se documenta
esa decisión y cómo se valida la comparabilidad resultante?

Seguirá JBI para diseño y ejecución y PRISMA-ScR para reporte
[@peters2024jbi; @tricco2018prismascr]. Incluirá literatura publicada y gris
predefinida. No realizará metaanálisis salvo que una futura pregunta distinta
identifique un estimando común, circunstancia no prevista para este WP.

El protocolo operativo, elegibilidad, fuentes, selección, charting y síntesis se
mantienen en `research/scoping-review/protocol.md`. El corpus narrativo previo se
conserva como búsqueda piloto y no se transforma automáticamente en selección
definitiva de WP1. La búsqueda bibliográfica utiliza tres líneas independientes:
armonización retrospectiva explícita; comparabilidad de constructos y medidas;
y marcos e infraestructuras operativas. Sus resultados se combinan únicamente
después de la recuperación, conservando base, línea, estrategia y archivo de
origen.

## 11. Desarrollo del DataSchema

Las variables objetivo se organizarán por constructos:

1. sociodemografía;
2. posición socioeconómica;
3. estado de salud general;
4. enfermedades crónicas y multimorbilidad;
5. salud mental y bienestar;
6. funcionamiento y limitación;
7. conductas relacionadas con la salud;
8. acceso y necesidades no atendidas;
9. utilización sanitaria;
10. continuidad y coordinación;
11. atención centrada en la persona;
12. calidad y experiencia asistencial;
13. capacidades y automanejo;
14. características de la práctica o del sistema.

Cada variable objetivo definirá, antes del mapping:

- identificador y nombre normalizado;
- constructo y definición conceptual;
- uso analítico permitido;
- población y reglas de aplicabilidad;
- tipo, categorías o unidad;
- periodo de referencia;
- tipos de ausencia y valores no sustantivos;
- fuentes candidatas;
- transformaciones admisibles;
- pérdida de información tolerable;
- limitaciones, versión, estado y responsables.

## 12. Evaluación del potencial de armonización

### 12.1. Dimensiones

Dos revisores evaluarán independientemente:

1. equivalencia conceptual;
2. instrumento o medida;
3. redacción;
4. población y universo;
5. periodo de referencia;
6. filtros y saltos;
7. escala y representación;
8. derivación;
9. modo de administración;
10. contexto dentro del cuestionario;
11. adaptaciones nacionales;
12. pérdida de información.

### 12.2. Clasificación de potencial

La etiqueta de síntesis para comunicar el potencial será:

- `IDENTICAL`;
- `COMPATIBLE`;
- `PARTIALLY_COMPATIBLE`;
- `INCOMPATIBLE`;
- `UNAVAILABLE`.

Esta taxonomía es operativa del proyecto y no se atribuye como vocabulario
literal de Maelstrom. Las clases técnicas existentes se conservan y se cruzan
así:

| Clase técnica | Interpretación habitual | Potencial posible |
|---|---|---|
| `DIRECT` | Generación directa sin pérdida relevante | `IDENTICAL` o `COMPATIBLE` |
| `RECODABLE` | Recodificación determinista | `COMPATIBLE` o `PARTIALLY_COMPATIBLE` |
| `DERIVABLE` | Combinación o algoritmo explícito | `COMPATIBLE` o `PARTIALLY_COMPATIBLE` |
| `PARTIAL` | Solapamiento incompleto | `PARTIALLY_COMPATIBLE` |
| `RELATED` | Constructo o medida relacionada | `INCOMPATIBLE` para pooling directo |
| `NONE` | Información insuficiente o ausente | `INCOMPATIBLE` o `UNAVAILABLE` |

La correspondencia se decidirá por variable y uso; no se aplicará
mecánicamente. Los estados seguirán siendo `PROPOSED`, `REVIEWED`, `VALIDATED`,
`REJECTED` y `UNRESOLVED`.

### 12.3. Revisión y adjudicación

Los dos revisores trabajarán de forma independiente. Las discrepancias se
resolverán por discusión documentada y, si persisten, por adjudicación. Se
informarán acuerdo y patrones de desacuerdo, sin usar kappa como sustituto de la
justificación científica. Los métodos automáticos solo podrán proponer
candidatos o comprobar coherencia.

## 13. Procesamiento y algoritmos

Cada algoritmo tendrá:

- variables originales y fuente exacta;
- universo, filtros y precondiciones;
- reglas de transformación;
- tratamiento separado de ausencia estructural, no aplicable, rechazo,
  desconocido y no recogido;
- supuestos y pérdida de información;
- versión de datos y algoritmo;
- autoría, revisión y estado;
- pruebas automatizadas con datos sintéticos.

La salida conservará como mínimo encuesta, país, año u ola, identificador
interno permitido, peso, estrato, conglomerado, versión de origen, algoritmo y
grado de armonización. La procedencia no se borrará al crear una variable común.

## 14. Evaluación empírica

El plan será escalonado:

1. cobertura y disponibilidad por variable, encuesta y país;
2. missingness, aplicabilidad y pérdida de información;
3. distribuciones y prevalencias ponderadas bajo el diseño original;
4. efectos suelo y techo cuando sean pertinentes;
5. restricción progresiva a poblaciones comparables;
6. estandarización por edad, sexo, educación, multimorbilidad y otras variables
   realmente comunes;
7. calibración o ponderación de transportabilidad solo cuando el estimando, la
   positividad y los supuestos sean identificables;
8. cuantificación del efecto encuesta;
9. validez nomológica mediante asociaciones preespecificadas;
10. análisis de sensibilidad.

La similitud distributiva podrá detectar problemas, pero nunca demostrará por sí
sola equivalencia conceptual.

## 15. Estrategia estadística

### 15.1. Enfoque en dos etapas

1. Estimar cada resultado por separado dentro de cada encuesta y país,
   respetando pesos, estratos, conglomerados y niveles adicionales disponibles.
2. Comparar o sintetizar posteriormente las estimaciones, modelando
   heterogeneidad y sin tratar todas las observaciones como una sola muestra.

La concatenación física, si se utiliza para orquestación, mantendrá identificada
la procedencia y no implicará un diseño muestral común.

### 15.2. Comparaciones

Según el tipo de variable se considerarán prevalencias, medias, distribuciones
ordinales, diferencias absolutas o estandarizadas y razones interpretables. Se
informarán intervalos compatibles con el diseño. Los modelos entre encuestas
incluirán un efecto o contraste explícito de encuesta y evaluarán interacción
encuesta–covariable cuando corresponda a la pregunta de transportabilidad.

### 15.3. Validez nomológica

Antes de consultar los resultados se definirán asociaciones esperadas por
dirección y, cuando sea defendible, orden relativo. Se compararán dentro de cada
fuente; una asociación parecida no reparará una falta de equivalencia de
contenido.

### 15.4. Invariancia, DIF, linking y equating

No se aplicarán por defecto ni a variables aisladas. Solo se considerarán si
existen un constructo común, varios ítems suficientemente equivalentes, anclajes
compartidos o una muestra puente, tamaño adecuado e identificación defendible.
Se requerirá evaluar invariancia y sensibilidad a los ítems ancla. La ausencia
de estas condiciones implicará no usar IRT, DIF, linking o equating.

## 16. Piloto PaRIS–EHIS

El producto mínimo viable probará el proceso completo con PaRIS y EHIS antes de
añadir encuestas. Salud autopercibida y hospitalización conservarán su papel de
benchmark OECD. El conjunto piloto definitivo incluirá además únicamente
variables necesarias para definir población y diseño y una selección pequeña de
constructos que represente distintos problemas de armonización. No se ampliará a
todas las variables hasta que los criterios y algoritmos hayan sido revisados.

El piloto permitirá clasificar cada conclusión del benchmark como
`REPRODUCED`, `APPROXIMATELY_REPRODUCED`, `SENSITIVE`, `NOT_ASSESSABLE` o
`DISCREPANT`, pero estas etiquetas describen reproducibilidad, no equivalencia.

## 17. Gestión de datos

`data/raw` será inmutable. Cada fichero autorizado tendrá versión, hash,
licencia, fecha, alcance, ubicación y restricciones. Los derivados se escribirán
en `interim`, `processed`, `outputs` o `logs`. Antes de incorporar microdatos se
inventariarán:

- archivos y documentación;
- licencias y condiciones de acceso;
- identificadores y estructura;
- códigos de ausencia;
- pesos, estratos y conglomerados;
- niveles de práctica, hogar o persona;
- reglas de disclosure;
- país, periodo, ola y versión.

Las bases analíticas armonizadas se generarán localmente o en entornos seguros.
No se presume que puedan redistribuirse.

## 18. Reproducibilidad y control de versiones

- funciones reutilizables en `R/` y scripts de orquestación numerados;
- rutas definidas mediante `scripts/00_setup.R` y `config/paths.R`;
- catálogos, mappings, algoritmos y decisiones versionados;
- tests sintéticos para funciones puras y transformaciones;
- outputs regenerables con versión de datos, algoritmo, parámetros y commit;
- revisión independiente de mappings y algoritmos críticos;
- registro prospectivo de enmiendas;
- control de disclosure antes de publicar tablas o figuras.

## 19. Consideraciones éticas y legales

El proyecto utiliza documentación pública y microdatos secundarios sujetos a
autorización. No se subirán a Git microdatos, datos individuales derivados,
credenciales, documentación restringida ni resultados que incumplan disclosure.
Se respetarán las licencias y condiciones de OECD, Eurostat y cada proveedor.
La aprobación ética o exención necesaria se determinará para cada fuente y
entorno antes del análisis.

## 20. Gobernanza

JALR será investigador principal y aprobará protocolo, DataSchema, mappings,
algoritmos y enmiendas. Un segundo investigador revisará independientemente la
elegibilidad de WP1 y los assessments primarios. Las discrepancias tendrán
registro, rationale, fecha y resolución. Las propuestas automáticas no
adjudicarán ni convertirán similitud semántica en equivalencia.

## 21. Limitaciones previstas

- disponibilidad desigual de microdatos, documentación y diseño;
- poblaciones que no reproducen el marco PaRIS;
- desfases temporales y cambios de sistema;
- adaptaciones nacionales y traducciones;
- diferencias de modo, contexto y respuesta;
- pérdida por categorización o anonimización;
- solapamiento limitado de PREMs;
- confusión entre efecto encuesta, población, país y periodo;
- selección de variables condicionada por disponibilidad;
- recursos insuficientes para evaluar todas las encuestas simultáneamente.

La escalabilidad se demostrará mediante un proceso reutilizable, no por incluir
de inicio el máximo número de fuentes.

## 22. Productos y difusión

1. scoping review sistemática;
2. inventario de iniciativas, métodos y software;
3. selección justificada de encuestas;
4. DataSchema/common data model versionado;
5. matriz de equivalencia variable–encuesta;
6. algoritmos reproducibles por fuente;
7. bases armonizadas locales según licencia;
8. informe de comparabilidad y transportabilidad;
9. repositorio reproducible;
10. artículo metodológico;
11. protocolo posterior para la aplicación sobre atención primaria,
    multimorbilidad y desigualdades.

Los productos públicos serán principalmente documentación, metadatos, código,
algoritmos y resultados agregados. La web facilitará seguimiento y anotación,
pero no sustituirá los archivos canónicos del repositorio.

## 23. Cronograma y puertas de decisión

El cronograma operativo se mantiene en
`documentation/planning/work-packages.csv`. Las puertas principales son:

1. aprobación del protocolo v0.3;
2. congelación y registro del protocolo WP1;
3. inventario de viabilidad del núcleo;
4. DataSchema piloto revisado por dos investigadores;
5. algoritmos sintéticos validados;
6. autorización antes de usar microdatos;
7. evaluación del piloto antes de ampliar a SHARE o IHP;
8. enmienda prospectiva antes de una aplicación sustantiva.

## 24. Riesgos y decisiones pendientes

Permanecen pendientes:

- aprobación formal del alcance v0.3;
- disponibilidad real y licencias de cada microdato;
- elección de olas/años para encuestas distintas de PaRIS y EHIS;
- selección definitiva de países del piloto;
- variables de diseño disponibles por fuente;
- composición exacta del DataSchema mínimo viable;
- umbrales de aceptación de comparabilidad empírica;
- plataforma de registro público del protocolo y WP1;
- identidad y disponibilidad del segundo investigador;
- recursos para ampliaciones y entornos seguros.

El registro detallado se mantiene en
`documentation/planning/risk-register.csv` y
`harmonisation/decisions/decision_log.csv`.

## Referencias

Las referencias bibliográficas completas se mantienen en
`manuscript/references.bib` y se renderizan en la versión Quarto.

## Anexos

### Anexo A. Artefactos operativos

- Matriz de preguntas y objetivos:
  `documentation/planning/research-questions.csv`.
- Inventario de encuestas: `documentation/inventories/survey-inventory.csv`.
- Plantilla DataSchema: `harmonisation/templates/dataschema-template.csv`.
- Plantilla de equivalencia:
  `harmonisation/templates/equivalence-matrix-template.csv`.
- Protocolo WP1: `research/scoping-review/protocol.md`.
- Plantilla de extracción WP1:
  `research/scoping-review/extraction-template.csv`.
- Auditoría de búsquedas:
  `research/scoping-review/search-strategy-audit.md`.
- Estrategias A/B/C por plataforma:
  `research/scoping-review/strategies/search-strategies-v0.2.csv`.
- Matriz pregunta–conceptos–términos–elegibilidad–extracción:
  `research/scoping-review/strategies/concept-term-matrix.csv`.
- Referencias semilla y validación real:
  `research/scoping-review/seed-references.csv` y
  `research/scoping-review/seed-validation.csv`.
- Ejecuciones y subconsultas Scopus:
  `research/scoping-review/manifests/search-runs.csv` y
  `research/scoping-review/manifests/scopus-subqueries.csv`.

### Anexo B. Informe OECD 2026

- DOI: `10.1787/acf46da9-en`.
- Archivo local: `documentation/protocol/sources/oecd-2026-comparison.pdf`.
- Evaluación:
  `documentation/protocol/sources/oecd-2026-comparison-assessment.md`.
- Manifiesto: `documentation/protocol/sources/manifest.csv`.

### Anexo C. Trabajo anterior conservado

El protocolo v0.2 de réplica OECD se conserva en
`documentation/protocol/archive/protocol-v0.2.md`. El corpus bibliográfico, sus
decisiones JALR, las búsquedas multibase, D1 y la interfaz permanecen
versionados. No constituyen automáticamente la selección de WP1 bajo los nuevos
criterios.
