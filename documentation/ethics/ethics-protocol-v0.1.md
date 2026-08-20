# Protocolo para evaluación por el Comité de Ética de la Investigación {.unnumbered .unlisted}

## 1. Identificación del proyecto

**Título:** Armonización retrospectiva de las encuestas PaRIS y European Health
Interview Survey (EHIS): desarrollo y validación de un modelo común de
conceptos, medidas y variables para el análisis comparativo de resultados de
salud y atención sanitaria

**Acrónimo:** PaRISEHIS Harmonisation Project<br>
**Versión:** 0.1<br>
**Fecha:** 20 de agosto de 2026<br>
**Investigador/a principal:** `[NOMBRE Y APELLIDOS]`<br>
**Centro/departamento:** `[CENTRO Y DEPARTAMENTO]`<br>
**Equipo investigador:** `[MIEMBROS Y FUNCIONES]`<br>
**Duración prevista:** `[FECHA DE INICIO – FECHA DE FIN]`<br>
**Financiación:** `[INDICAR FINANCIACIÓN O AUSENCIA DE FINANCIACIÓN]`

## 2. Resumen

Se propone un estudio metodológico basado en el uso secundario de datos y
documentación de dos encuestas internacionales de salud: Patient-Reported
Indicator Surveys (PaRIS), Cycle 1, de la OECD, y European Health Interview
Survey (EHIS), principalmente Wave 3, de Eurostat.

El propósito es determinar qué conceptos y variables de ambas encuestas pueden
compararse de forma científicamente válida, qué transformaciones requieren y
qué variables no deben considerarse equivalentes. El proyecto desarrollará un
modelo común de metadatos, variables objetivo, mappings y algoritmos de
transformación. Posteriormente, cuando se disponga de autorización y acceso a
los microdatos, se realizará una validación empírica mediante análisis
secundario.

No se reclutarán participantes, no habrá contacto con las personas encuestadas,
no se realizarán intervenciones y el equipo no accederá a nombres, direcciones
ni otros identificadores directos. El tratamiento se limitará a los usos
autorizados por los proveedores y por la institución responsable.

## 3. Antecedentes y justificación

PaRIS recoge resultados y experiencias comunicados por personas de 45 años o
más que han tenido contacto reciente con atención primaria. EHIS es una
encuesta poblacional europea de salud dirigida, con carácter general, a
personas de 15 años o más residentes en hogares privados.

Aunque ambas fuentes contienen información sociodemográfica, de salud y de uso
de servicios, fueron diseñadas con finalidades, poblaciones, instrumentos y
periodos diferentes. La coincidencia del nombre de una variable no garantiza
que represente el mismo concepto ni que sea intercambiable. Una armonización
incorrecta podría producir estimaciones sesgadas o conclusiones engañosas.

El proyecto sigue los principios de armonización retrospectiva de Maelstrom y
un modelo inspirado en DDI: se definirá primero una variable objetivo y después
se evaluará por separado si cada encuesta permite generarla, atendiendo a
concepto, medida, universo, tiempo, representación, derivación y administración.

## 4. Objetivos

### Objetivo principal

Desarrollar y validar un marco reproducible para determinar qué variables de
PaRIS Cycle 1 y EHIS Wave 3 pueden utilizarse comparativamente y bajo qué
condiciones.

### Objetivos específicos

1. Inventariar y normalizar los metadatos disponibles.
2. Definir dominios, conceptos, medidas, universos y variables objetivo.
3. Evaluar la compatibilidad de cada relación entre variable fuente y objetivo.
4. Clasificar las relaciones como `DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`,
   `RELATED` o `NONE`.
5. Implementar algoritmos independientes para PaRIS y EHIS.
6. Validar conceptualmente los mappings y documentar los desacuerdos.
7. Evaluar empíricamente las variables armonizadas cuando exista acceso
   autorizado a los microdatos.
8. Analizar la sensibilidad a definiciones alternativas de variables y
   poblaciones.
9. Mantener trazabilidad completa de fuentes, decisiones, código y resultados.

## 5. Diseño

Estudio metodológico de armonización retrospectiva seguido, si se autoriza el
acceso, de análisis secundario de microdatos.

El estudio tendrá dos componentes:

1. **Armonización conceptual y metodológica:** análisis de cuestionarios,
   diccionarios, manuales y metadatos; definición de objetivos y mappings.
2. **Validación empírica:** aplicación de algoritmos a microdatos, controles de
   calidad, análisis del diseño muestral y sensibilidad.

La validación distributiva no se utilizará como sustituto de la equivalencia
conceptual.

## 6. Fuentes de datos

### 6.1. PaRIS Cycle 1

Se utilizarán el cuestionario, codebook, diccionario, documentación metodológica
y Public Use Files (PUF) de los países cuya difusión y uso hayan sido
autorizados. Según la OECD, los PUF de Cycle 1 contienen datos de 2023–2024 de
15 países y se acompañan de documentación sobre variables, códigos y
missingness.

El equipo verificará y archivará la versión vigente del formulario de acceso,
licencia y condiciones de uso antes de tratar los datos. La denominación PUF no
se interpretará por sí sola como autorización para cualquier reutilización,
redistribución o intento de enlace.

### 6.2. EHIS Wave 3

Se utilizarán manuales, cuestionarios, metadatos, reglas de anonimización y,
cuando exista contrato válido, microdatos científicos de EHIS Wave 3. EHIS no
contiene identificadores administrativos directos en los ficheros difundidos,
pero Eurostat aplica supresión, agrupación, recodificación u otras medidas para
reducir el riesgo de identificación.

El acceso a microdatos EHIS se solicitará exclusivamente a través de una entidad
de investigación reconocida y para el proyecto, investigadores, lugares y
periodo aprobados. Se respetarán el contrato, la declaración de
confidencialidad, las reglas de publicación y la obligación de destrucción o
devolución al finalizar el periodo autorizado.

### 6.3. Datos que no se utilizarán

- nombres, domicilios, documentos de identidad o información de contacto;
- historias clínicas obtenidas directamente de centros sanitarios;
- datos genéticos o muestras biológicas;
- geolocalización precisa no incluida y autorizada por el proveedor;
- enlaces con registros externos, salvo futura modificación evaluada y
  autorizada de forma independiente;
- datos obtenidos fuera de las condiciones de licencia.

## 7. Población y unidad de análisis

La unidad primaria será la persona encuestada. Las poblaciones originales de
PaRIS y EHIS no son equivalentes. Se analizarán de manera escalonada:

1. poblaciones originales;
2. restricción común por edad;
3. aproximación al contacto con atención primaria;
4. máxima población común reproducible con las variables autorizadas.

La creación de una subpoblación comparable no implicará identificar ni
contactar participantes.

## 8. Variables y categorías de datos

Según disponibilidad y necesidad científica, podrán tratarse:

- edad en la granularidad difundida;
- sexo y variables sociodemográficas;
- educación, situación laboral y otras características sociales;
- salud autopercibida y funcionamiento;
- enfermedades crónicas comunicadas por la persona;
- síntomas de salud mental y puntuaciones de instrumentos;
- conductas y determinantes de salud;
- utilización de servicios sanitarios;
- resultados y experiencias comunicados por pacientes;
- país, ola y periodo de recogida;
- pesos, estratos y unidades de diseño muestral autorizadas.

Se aplicará minimización: para cada análisis se extraerán únicamente las
variables necesarias. Los valores ausentes estructurales, no aplicables,
rechazos y desconocidos se mantendrán diferenciados cuando la fuente lo
permita.

## 9. Procedimiento

1. Registrar documentación, versión, licencia, hash y restricciones.
2. Normalizar metadatos sin modificar los archivos fuente.
3. Definir conceptos, universos y variables objetivo.
4. Evaluar cada mapping en siete dimensiones de compatibilidad.
5. Someter mappings críticos a revisión independiente o consenso documentado.
6. Programar transformaciones específicas para cada encuesta.
7. Verificar los algoritmos con datos sintéticos antes de aplicarlos a
   microdatos.
8. Ejecutar controles de rangos, frecuencias, missingness, denominadores y
   coherencia.
9. Realizar análisis ponderados y de sensibilidad cuando proceda.
10. Publicar únicamente resultados agregados que cumplan las reglas de
    confidencialidad aplicables.

## 10. Base jurídica, responsabilidades y evaluación institucional

La determinación de la base jurídica del tratamiento corresponde a la
institución responsable y deberá confirmarse con su Delegado/a de Protección de
Datos antes del acceso a microdatos. El equipo no asumirá que el interés
científico constituye por sí solo una base jurídica suficiente ni que todos los
archivos denominados anonimizados quedan necesariamente fuera de la normativa
de protección de datos.

Antes de iniciar la fase empírica se documentará:

- responsable y, en su caso, encargado del tratamiento;
- base jurídica aplicable y condición para datos de salud;
- finalidad autorizada y compatibilidad con el uso secundario;
- necesidad de registro de actividad de tratamiento;
- necesidad de evaluación de impacto relativa a la protección de datos;
- procedimiento para atender derechos o excepciones legalmente aplicables;
- transferencias o accesos internacionales, si existieran;
- contratos y compromisos de confidencialidad.

Las garantías para investigación científica incluirán minimización, control de
acceso, separación de fuentes, seudonimización o anonimización proporcionada por
los proveedores, limitación de conservación y prevención de divulgación.

## 11. Riesgos para las personas participantes

No existen riesgos físicos ni derivados de una intervención. El riesgo
principal es informacional: identificación indirecta, acceso no autorizado o
divulgación de características sensibles, especialmente mediante combinaciones
raras de país, edad, enfermedad u otras variables.

También existe un riesgo científico y social de producir comparaciones
inválidas que estigmaticen poblaciones o sistemas sanitarios. Para mitigarlo se
documentarán las limitaciones de equivalencia, no se presentarán variables
`PARTIAL` o `RELATED` como intercambiables y se evitarán interpretaciones
causales no justificadas.

El riesgo residual se considera `[MÍNIMO/BAJO, A CONFIRMAR POR LA INSTITUCIÓN]`
si se aplican íntegramente las medidas descritas y las condiciones del
proveedor.

## 12. Medidas de seguridad

- Los originales se almacenarán en una ubicación institucional autorizada y
  separada del repositorio de código.
- `data/raw` será inmutable y estará excluido de Git.
- El acceso se limitará nominalmente a investigadores autorizados, aplicando el
  principio de mínimo privilegio.
- Se utilizarán autenticación institucional y, cuando esté disponible,
  autenticación multifactor.
- No se enviarán microdatos por correo electrónico, mensajería o servicios
  personales de almacenamiento.
- No se copiarán microdatos a equipos o dispositivos no autorizados.
- Código, mappings y metadatos no confidenciales estarán versionados; los
  microdatos y derivados individuales no se subirán al repositorio remoto.
- Los secretos y credenciales se mantendrán fuera del código y de Git.
- Se conservará un registro de accesos, versiones, transformaciones y outputs
  cuando el entorno institucional lo permita.
- Se aplicarán actualizaciones de seguridad y copias de respaldo conforme a la
  política institucional.
- Cualquier incidente se notificará inmediatamente por los canales
  institucionales y contractuales establecidos.

Si una fuente exige un entorno seguro, todo el análisis se ejecutará en dicho
entorno y únicamente se extraerán resultados aprobados.

## 13. Confidencialidad y control de divulgación

No se intentará identificar, reidentificar ni contactar a ninguna persona. No
se enlazarán registros individuales entre PaRIS y EHIS: el propósito es
armonizar definiciones y comparar estimaciones, no encontrar a la misma persona
en ambas encuestas.

Antes de difundir tablas o figuras se aplicarán las reglas contractuales más
restrictivas pertinentes. Para EHIS se tendrá en cuenta que Eurostat desaconseja
publicar estimaciones basadas en menos de 20 observaciones y exige señalización
de baja fiabilidad en determinados supuestos; estas reglas generales se
complementarán con las condiciones específicas entregadas con los microdatos.
Se evitarán celdas pequeñas, cruces de alta dimensionalidad, listados de casos,
valores extremos identificables y resultados que faciliten inferencias sobre
individuos.

## 14. Conservación, destrucción y reproducibilidad

Los datos se conservarán únicamente durante el periodo autorizado por cada
proveedor y por la institución. Al finalizar:

- se destruirán o devolverán originales y derivados confidenciales según el
  contrato;
- se documentará la destrucción cuando sea requerida;
- se conservarán únicamente código, metadatos no confidenciales, mappings,
  decisiones y resultados agregados cuya conservación esté permitida;
- las publicaciones y productos exigidos se comunicarán al proveedor.

Cada resultado permitido será trazable a versión de datos, mapping, algoritmo,
parámetros y commit, sin exponer microdatos.

## 15. Consentimiento informado y dispensa

Este proyecto no realizará una nueva recogida ni contacto con participantes.
Solicita al Comité que valore la procedencia de una dispensa de consentimiento
específico para este análisis secundario, condicionada a que:

1. los proveedores hayan obtenido y gestionado legítimamente los datos;
2. el uso se encuentre dentro de las finalidades y contratos autorizados;
3. el equipo no reciba identificadores directos;
4. el riesgo informacional se reduzca mediante las garantías descritas;
5. no se intente reidentificar ni enlazar individuos.

La dispensa solicitada no sustituye los contratos de acceso ni la determinación
institucional de la base jurídica.

## 16. Beneficios esperados

No se prevé beneficio directo para las personas participantes. El beneficio
social esperado es mejorar la validez y transparencia de las comparaciones
internacionales de salud y atención sanitaria, evitar equivalencias incorrectas
y generar herramientas reutilizables para investigación responsable.

## 17. Plan de análisis

La fase piloto incluirá edad, sexo/género, salud autopercibida, diabetes,
utilización sanitaria, una escala común y un PREM PaRIS sin equivalente. Para
cada objetivo se evaluarán compatibilidad, algoritmo, missingness y población.

Los análisis empíricos incluirán estimaciones descriptivas, ponderaciones,
diseño muestral, comparaciones por país y escenarios poblacionales. Los métodos
de linking o variable latente se utilizarán únicamente si existe constructo
común y anclaje defendible, con evaluación de invariancia y sensibilidad.

## 18. Publicación y comunicación

Los resultados podrán difundirse en artículos, congresos, informes y materiales
metodológicos. Se declararán las fuentes, versiones, financiación, conflictos de
interés y limitaciones. No se publicarán microdatos ni derivados individuales.
Las reglas de reconocimiento y revisión previa establecidas por OECD, Eurostat
u otros proveedores se cumplirán antes de cualquier difusión.

Los resultados negativos —variables no armonizables— se comunicarán con el
mismo rigor que los positivos.

## 19. Conflictos de interés

`[DECLARAR CONFLICTOS O INDICAR QUE NO EXISTEN]`.

## 20. Documentos que deben acompañar la solicitud

1. Protocolo científico vigente.
2. Currículum abreviado del investigador principal.
3. Composición y funciones del equipo.
4. Plan institucional de gestión de datos.
5. Dictamen o consulta al Delegado de Protección de Datos.
6. Contrato/licencia PaRIS y condiciones de los PUF.
7. Solicitud, contrato y declaración de confidencialidad de Eurostat/EHIS.
8. Reglas de publicación y disclosure aplicables.
9. Diagrama de flujo de datos y arquitectura de almacenamiento.
10. Declaración de financiación y conflictos de interés.
11. Justificación de dispensa de consentimiento.
12. Plan de respuesta ante incidentes y destrucción de datos.

## 21. Aspectos pendientes antes de presentar

- Completar identidad, institución, equipo, financiación y calendario.
- Confirmar qué archivos PaRIS y EHIS se usarán y bajo qué licencia.
- Determinar responsable/encargado, base jurídica y condición aplicable a datos
  de salud con el Delegado de Protección de Datos.
- Decidir si procede una evaluación de impacto.
- Describir el servidor Ubuntu/RStudio real: responsable, ubicación, cifrado,
  copias, logs, control de acceso y borrado.
- Incorporar las reglas exactas de disclosure de cada contrato.
- Confirmar el plazo de conservación y el procedimiento de destrucción.
- Adaptar el documento al formulario y terminología del Comité competente.

## 22. Referencias normativas y metodológicas principales

- Reglamento (UE) 2016/679, Reglamento General de Protección de Datos.
- Reglamento (CE) 223/2009 relativo a la estadística europea.
- Reglamento (UE) 557/2013 sobre acceso a datos confidenciales con fines
  científicos.
- Condiciones y guías vigentes de acceso a microdatos de Eurostat.
- Documentación oficial de EHIS Wave 3 y PaRIS Cycle 1.
- Fortier I, Raina P, van den Heuvel ER, et al. Maelstrom Research guidelines
  for rigorous retrospective data harmonization. *Int J Epidemiol*.
  2017;46(1):103–105.
- Data Documentation Initiative, Lifecycle 3.3.

---

> Este documento es un borrador científico y operativo. La calificación
> jurídica, la base de legitimación, la necesidad de evaluación de impacto y la
> decisión sobre consentimiento o dispensa corresponden a la institución, su
> Delegado de Protección de Datos y el Comité de Ética competente.
