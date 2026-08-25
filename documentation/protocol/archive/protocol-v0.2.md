# Protocolo de investigación v0.2

> **Documento histórico.** Esta propuesta de réplica OECD fue sustituida por
> el protocolo multifuente v0.3. Sus componentes válidos se conservan como
> benchmark y piloto PaRIS–EHIS; no representa el protocolo vigente.

## Título provisional

**Reproducibilidad y robustez de la comparación entre PaRIS Cycle 1 y EHIS
Wave 3: réplica metodológica, evaluación multidimensional de comparabilidad y
análisis de sensibilidad**

**Acrónimo de trabajo:** PaRISEHIS-R<br>
**Versión:** 0.2, propuesta de reorientación<br>
**Fecha:** 24 de agosto de 2026<br>
**Estado:** borrador avanzado pendiente de confirmación del investigador principal<br>
**Referencia desencadenante:** OECD (2026), DOI
[`10.1787/acf46da9-en`](https://doi.org/10.1787/acf46da9-en)

## 1. Cambio respecto al protocolo v0.1

El protocolo v0.1 proponía desarrollar una armonización retrospectiva general
entre PaRIS Cycle 1 y EHIS Wave 3. El informe publicado por la OCDE el 15 de
julio de 2026 ya compara ambas encuestas y ejecuta mapeo de dominios, crosswalk
de ítems, armonización de respuestas, restricción poblacional y
estandarización. Por tanto, la comparación general ha dejado de ser una
contribución original suficiente.

La versión 0.2 conserva el marco de trazabilidad construido, pero cambia la
pregunta científica. El interés principal pasa a ser la reproducibilidad de la
comparación publicada, la dependencia de sus resultados respecto de decisiones
metodológicas y los límites de interpretación de una cifra «armonizada».

El protocolo v0.1 y los flujos de revisión bibliográfica, web y agentes se
conservan como antecedentes, pero quedan suspendidos hasta que se confirme este
nuevo alcance.

## 2. Antecedentes y justificación

PaRIS y EHIS comparten algunos temas, pero responden a finalidades, poblaciones
y diseños diferentes. PaRIS estudia personas de 45 o más años con contacto
reciente con atención primaria mediante un diseño anidado de pacientes en
prácticas. EHIS es una encuesta poblacional de personas de 15 o más años en
hogares privados, implementada mediante los sistemas estadísticos nacionales.
Estas diferencias afectan al significado de los estimandos y no desaparecen
necesariamente al restringir o ponderar las muestras.

El informe OECD (2026) identifica 16 preguntas potencialmente comparables entre
PaRIS y otras encuestas y analiza cuatro indicadores. En la comparación
PaRIS–EHIS, los resultados detallados se centran en salud autopercibida y
hospitalización para trece países. Las estimaciones se restringen a personas de
45 o más años con enfermedades crónicas y contacto sanitario reciente, y se
postestratifican a una referencia PaRIS por edad y sexo.

El informe demuestra que la armonización cambia las diferencias observadas y,
en ocasiones, su dirección. También deja decisiones que el documento público no
permite reconstruir por completo: definiciones operativas, variables exactas,
interacción entre pesos originales y calibración, estimación de varianza,
missingness y ciertas reglas de recodificación. Esto crea una pregunta
metodológica relevante: qué conclusiones son reproducibles y robustas bajo un
conjunto preespecificado de decisiones plausibles.

## 3. Pregunta principal

¿En qué medida pueden reproducirse las comparaciones PaRIS–EHIS publicadas por
la OCDE para salud autopercibida y hospitalización, y qué parte de sus
conclusiones depende de las decisiones sobre medición, población,
estandarización, diseño muestral y datos ausentes?

## 4. Objetivos

### 4.1. Objetivo principal

Reproducir y evaluar la robustez metodológica de las comparaciones entre PaRIS
Cycle 1 y EHIS Wave 3 publicadas por OECD (2026), sin interpretar como
equivalentes medidas que solo sean textualmente o distributivamente similares.

### 4.2. Objetivos específicos

1. Reconstruir las definiciones, cohortes analíticas, recodificaciones y
   ponderaciones del informe con trazabilidad a variables y versiones de datos.
2. Replicar, hasta donde lo permitan los materiales disponibles, las
   prevalencias y diferencias por país para salud autopercibida y
   hospitalización.
3. Evaluar por separado la compatibilidad de concepto, medida, población,
   periodo, representación, derivación y administración.
4. Cuantificar cómo cambian los estimandos al aplicar secuencialmente criterios
   de edad, cronicidad, contacto sanitario y disponibilidad de información.
5. Comparar estrategias alternativas de categorización, estandarización,
   ponderación, varianza y tratamiento de datos ausentes.
6. Clasificar cada conclusión publicada como reproducida, aproximadamente
   reproducida, sensible, no evaluable o discrepante, con criterios previos.
7. Explorar indicadores adicionales únicamente después de demostrar
   compatibilidad preestadística y sin presentarlos como resultados
   confirmatorios del objetivo principal.

## 5. Hipótesis y expectativas preespecificadas

- **H1.** La restricción poblacional reducirá algunas diferencias brutas, pero
  no eliminará sistemáticamente las diferencias entre encuestas.
- **H2.** La dirección o magnitud de determinadas diferencias será sensible a
  la dicotomización de salud autopercibida y al estándar demográfico elegido.
- **H3.** Incorporar correctamente pesos, estratos y conglomerados modificará
  principalmente la incertidumbre y podrá alterar la fuerza de las conclusiones,
  aunque no necesariamente las estimaciones puntuales.
- **H4.** Hospitalización tendrá mayor compatibilidad de medida que salud
  autopercibida, pero mantendrá diferencias de selección y marco poblacional.
- **H5.** No todas las diferencias residuales podrán atribuirse a desempeño
  sanitario; persistirán explicaciones alternativas por modo, periodo, selección
  y funcionamiento de las escalas.

Estas hipótesis no autorizan análisis dirigidos a confirmar una dirección. Las
especificaciones y excepciones se congelarán antes de consultar distribuciones
de resultados.

## 6. Diseño

Estudio metodológico de datos secundarios con cuatro componentes enlazados:

1. **réplica documental**, para reconstruir el análisis publicado;
2. **armonización preestadística**, para evaluar el significado de cada
   variable antes de observar resultados;
3. **réplica empírica**, mediante algoritmos independientes por encuesta;
4. **análisis de sensibilidad multiespecificación**, limitado a decisiones
   científicamente defendibles y declaradas de antemano.

El informe seguirá STROBE para el componente transversal y las recomendaciones
de Maelstrom para armonización retrospectiva. Las guías se usarán para mejorar
el diseño y la comunicación, no como escalas de calidad.

## 7. Fuentes de datos y documentación

### 7.1. Benchmark publicado

- OECD (2026), *Comparing patient-reported outcome and experience measures in
  international health surveys*.
- El PDF local, DOI, licencia y hash se registran en
  `documentation/protocol/sources/manifest.csv`.
- Las cifras publicadas se tratarán como benchmark externo, nunca como datos de
  entrenamiento para ajustar las decisiones de armonización.

### 7.2. PaRIS Cycle 1

Se utilizarán el cuestionario, codebook, diccionario, metodología, PUF y
variables de diseño autorizadas. Se registrarán país, versión, fecha, tamaño,
hash, licencia y restricciones. La estructura paciente–práctica–país se
preservará cuando los identificadores y el diseño lo permitan.

### 7.3. EHIS Wave 3

Se utilizarán el manual metodológico, cuestionario modelo, reglas de
anonimización, ficheros y variables de diseño autorizados. Se documentarán las
desviaciones nacionales, modos de administración, periodos de campo y
limitaciones derivadas de anonimización o acceso.

### 7.4. Inmutabilidad y versiones

`data/raw` será inmutable. Cada análisis declarará fuente, versión, hash,
algoritmo, parámetros y commit. Los derivados se escribirán en `interim`,
`processed`, `outputs` o `logs`.

## 8. Ámbito, países y participantes

### 8.1. Países candidatos

El universo inicial son los trece países coincidentes declarados por OECD
(2026): Bélgica, Chequia, Francia, Grecia, Irlanda, Italia, Luxemburgo, Países
Bajos, Portugal, Rumanía, Eslovenia, España y Noruega. La inclusión final por
indicador exigirá datos, documentación y variables de diseño suficientes.

Las exclusiones de países se decidirán por criterios documentales o técnicos
previos y nunca por el tamaño o dirección del resultado.

### 8.2. Poblaciones de origen

- **PaRIS:** personas de 45 o más años con contacto reciente con la práctica de
  atención primaria seleccionada.
- **EHIS:** personas de 15 o más años residentes en hogares privados, según la
  implementación nacional de Wave 3.

### 8.3. Embudo poblacional preespecificado

Se producirán estimandos separados, sin asumir que una restricción convierte
una población en la otra:

1. población original de cada encuesta;
2. personas de 45 o más años;
3. personas de 45 o más años con al menos una condición crónica comparable;
4. población anterior con contacto sanitario reciente armonizable;
5. máxima población común reproducible, si puede definirse sin variables
   sustitutas débiles.

Cada etapa informará recuento no ponderado, proporción ponderada, exclusiones y
missingness. «Contacto sanitario» y «enfermedad crónica» requieren definiciones
source-specific y un assessment formal antes de crear la población común.

## 9. Indicadores y variables objetivo

### 9.1. Indicadores primarios

#### Salud general autopercibida

Se preservarán primero las escalas ordinales originales. La réplica binaria
evaluará la definición publicada:

- PaRIS: `excellent`, `very good` o `good` frente a `fair` o `poor`;
- EHIS: `very good` o `good` frente a `fair`, `bad` o `very bad`.

Esta recodificación produce un indicador operativo común, no equivalencia
psicométrica. Las alternativas incluirán distribución ordinal completa,
umbrales más estrictos y análisis que traten `fair` explícitamente.

#### Hospitalización en los últimos 12 meses

La variable objetivo primaria será cualquier ingreso con al menos una noche en
los últimos 12 meses. Los valores `not sure`, no aplicable y ausencia no se
colapsarán automáticamente con `no`.

### 9.2. Indicadores secundarios

Solo se incorporarán tras una evaluación ciega a resultados. Los candidatos
del anexo OECD incluyen tabaquismo, alcohol, fruta, verdura y acceso. Cada uno
deberá superar reglas explícitas de concepto, universo, periodo, formulación y
representación. Los PREMs sin equivalente EHIS actuarán como controles
negativos y no se forzarán a una variable común.

### 9.3. Modelo de compatibilidad

`domain -> concept -> measure -> source_variable -> assessment ->
target_variable -> algorithm -> harmonised_variable`

El assessment separará:

1. concepto;
2. medida o instrumento;
3. población/universo;
4. periodo de referencia;
5. representación y categorías;
6. derivación;
7. administración.

Las clases globales serán `DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`,
`RELATED` y `NONE`; los estados serán `PROPOSED`, `REVIEWED`, `VALIDATED`,
`REJECTED` y `UNRESOLVED`. Ninguna clase se inferirá solo del nombre o de la
distribución.

## 10. Estimandos

Por país, indicador, encuesta y población se estimarán:

- prevalencia o proporción bajo el diseño original;
- prevalencia estandarizada a la referencia demográfica elegida;
- diferencia absoluta PaRIS menos EHIS, en puntos porcentuales;
- razón de prevalencias como análisis secundario cuando sea interpretable;
- intervalos de confianza del 95 % compatibles con el diseño.

El estimando principal de réplica será la diferencia absoluta estandarizada en
la población común más próxima a la definición OECD. No se interpretará como
efecto causal de la encuesta ni como diferencia pura de desempeño sanitario.

## 11. Plan de análisis

### 11.1. Reconstrucción antes de microdatos

Se creará una especificación congelada con variables, etiquetas originales,
universos, filtros, categorías, códigos de ausencia, algoritmos y pesos. Las
ambigüedades del informe se enviarán, si es viable, a los autores u OECD. Las
respuestas se archivarán como procedencia, no se incorporarán de memoria.

### 11.2. Réplica descriptiva

Se reconstruirán primero las estimaciones de cada encuesta en su población
original y después cada etapa del embudo. Los algoritmos PaRIS y EHIS serán
independientes y se validarán con datos sintéticos antes de ejecutarse sobre
microdatos.

### 11.3. Ponderación y diseño complejo

Se identificarán peso final, estratos, unidades primarias, ajustes nacionales y
estructura de prácticas. No se sustituirán los pesos originales por calibración
sin documentar la consecuencia. Se compararán, como mínimo:

1. diseño original de cada encuesta;
2. diseño original más estandarización por edad y sexo;
3. especificación aproximada del informe OECD;
4. análisis no ponderado, solo como diagnóstico.

La combinación de cuatro bandas de edad (`45–54`, `55–64`, `65–74`, `75+`) y
dos categorías de sexo se implementará como ocho celdas salvo aclaración
documentada de la referencia a «cuatro celdas» del informe. Se comprobarán
celdas vacías, pesos extremos, efecto de diseño y tamaño muestral efectivo.

### 11.4. Estándares demográficos

La referencia PaRIS será la especificación principal de réplica. Como
sensibilidad se usarán, si son defendibles:

- distribución conjunta agrupada de la población analítica PaRIS–EHIS;
- población EHIS restringida;
- estándar europeo externo con año y fuente explícitos.

Los estándares se construirán con distribuciones conjuntas, no multiplicando
marginales de edad y sexo salvo que la independencia sea una decisión explícita.

### 11.5. Missingness

Se informará cada tipo de ausencia por encuesta, país, etapa e indicador. El
análisis completo será principal solo si el supuesto es defendible. Se
realizarán escenarios para códigos ambiguos y, cuando proceda, ponderación por
respuesta o imputación múltiple compatible con el diseño. Ausencia estructural,
no aplicable, rechazo, desconocido y no recogido permanecerán separados.

### 11.6. Sensibilidad multiespecificación

La cuadrícula mínima cruzará:

- población analítica;
- codificación del indicador;
- estándar demográfico;
- tratamiento del diseño;
- missingness;
- inclusión de países con desviaciones documentadas.

Solo se combinarán especificaciones defendibles. Se informará el rango de
estimaciones, estabilidad del signo, cambio de clasificación y contribución de
cada decisión. No se elegirá retrospectivamente la especificación más próxima
al informe.

### 11.7. Heterogeneidad

Se presentarán resultados por país. Los resúmenes entre países serán
secundarios y no ocultarán heterogeneidad de diseño o implementación. Cualquier
modelo jerárquico distinguirá país, práctica PaRIS e individuo, y no asumirá una
estructura equivalente inexistente en EHIS.

## 12. Evaluación de reproducibilidad

Antes del análisis se extraerán los valores benchmark de tablas o fuentes
numéricas oficiales. Si solo existen gráficos, se registrará la incertidumbre de
digitalización. Cada resultado se clasificará:

- `REPRODUCED`: misma definición y diferencia dentro de la tolerancia numérica;
- `APPROXIMATELY_REPRODUCED`: dirección y magnitud compatibles, con diferencias
  explicables por redondeo, versión o información incompleta;
- `SENSITIVE`: la conclusión cambia entre especificaciones defendibles;
- `NOT_ASSESSABLE`: faltan datos, código o definición esenciales;
- `DISCREPANT`: persiste una diferencia no explicada tras verificar entradas y
  consultar, cuando sea posible, a la fuente.

La tolerancia cuantitativa se fijará después de conocer la precisión de los
benchmarks, pero antes de calcular la réplica. `NOT_ASSESSABLE` no se contará
como fallo de reproducibilidad.

## 13. Sesgos y limitaciones

Se evaluarán explícitamente:

- selección por marco muestral, contacto sanitario y no respuesta;
- cobertura de personas institucionalizadas o fuera de hogares privados;
- diferencias de modo y deseabilidad social;
- desfase 2019 frente a 2023–2024, pandemia, estacionalidad y cambios del sistema;
- no equivalencia de anclajes, traducciones y respuesta ordinal;
- diferencias nacionales de implementación;
- residualidad tras restricciones poblacionales incompletas;
- inestabilidad por pesos extremos o celdas pequeñas;
- selección de indicadores condicionada por disponibilidad o resultados.

La estandarización controla únicamente las variables incluidas. No convierte
las encuestas en muestras de una misma población ni identifica la causa de las
diferencias residuales.

## 14. Control de calidad y reproducibilidad computacional

- funciones reutilizables en `R/` y orquestación numerada en `scripts/`;
- tests sintéticos para recodificación, filtros, pesos y missingness;
- diccionarios y mappings versionados;
- registro de decisiones científicas en
  `harmonisation/decisions/decision_log.csv`;
- semillas, versiones de paquetes y entorno reproducible;
- tablas de flujo con recuentos antes y después de cada filtro;
- revisión independiente de mappings y algoritmos críticos;
- control de disclosure antes de producir tablas o figuras públicas.

## 15. Ética, licencias y protección de datos

El estudio utiliza documentación pública y microdatos secundarios sujetos a
autorización. El PDF OECD está bajo CC BY 4.0 y se citará con atribución. Los
microdatos, credenciales, documentación restringida y resultados con riesgo de
identificación no se subirán a Git ni a la web pública. Se respetarán las
condiciones de PaRIS, Eurostat y cada entorno seguro.

## 16. Transparencia y difusión

El protocolo y sus enmiendas se fecharán antes de los análisis. Se publicarán
algoritmos, metadatos no restringidos, decisiones, resultados agregados y
limitaciones. La presentación seguirá STROBE y separará claramente:

- réplica de lo publicado;
- sensibilidades preespecificadas;
- análisis exploratorios;
- extensiones posteriores.

Una discrepancia o conclusión de no comparabilidad será un resultado válido.

## 17. Criterios de viabilidad y parada

La réplica empírica comenzará solo cuando se cumplan cuatro condiciones:

1. acceso legal y técnico a ambos conjuntos y a variables de diseño suficientes;
2. definición revisada de los dos indicadores y del embudo poblacional;
3. especificación congelada de pesos, estándares y missingness;
4. tests sintéticos superados.

Si no puede reconstruirse la población o ponderación principal, el proyecto se
limitará a auditoría documental y análisis parcial; no se rellenarán huecos con
supuestos silenciosos.

## 18. Roles y decisiones pendientes

JALR actuará como investigador principal y aprobará cada versión del protocolo.
La segunda persona investigadora revisará de forma independiente los mappings y
algoritmos primarios. Los métodos automáticos solo podrán proponer candidatos o
comprobar consistencia.

Antes de declarar la versión 1.0 deben decidirse:

- confirmación formal del nuevo alcance;
- países primarios y criterios de exclusión;
- disponibilidad real de microdatos y diseño;
- contacto con OECD para materiales analíticos;
- tolerancias de réplica;
- estatus confirmatorio o exploratorio de indicadores adicionales;
- estrategia de registro público del protocolo y sus enmiendas.

## 19. Trabajo suspendido

Hasta nueva decisión quedan en pausa:

- segunda revisión del corpus bibliográfico;
- precarga o ejecución del revisor LLM;
- ampliación del mapping a todo el inventario;
- desarrollo de algoritmos no vinculados a los indicadores primarios;
- cambios funcionales de la web de cribado.

Los artefactos existentes se preservan para trazabilidad y posible reutilización.

## Referencias principales

- OECD. *Comparing patient-reported outcome and experience measures in
  international health surveys*. OECD Publishing; 2026.
  doi:10.1787/acf46da9-en.
- Fortier I, Raina P, Van den Heuvel ER, et al. Maelstrom Research guidelines
  for rigorous retrospective data harmonization. *International Journal of
  Epidemiology*. 2017;46(1):103–105. doi:10.1093/ije/dyw075.
- von Elm E, Altman DG, Egger M, et al. The Strengthening the Reporting of
  Observational Studies in Epidemiology (STROBE) statement. *PLoS Medicine*.
  2007;4(10):e296. doi:10.1371/journal.pmed.0040296.
