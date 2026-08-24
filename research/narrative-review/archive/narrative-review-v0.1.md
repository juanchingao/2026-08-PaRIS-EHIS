# Revisión narrativa metodológica para la armonización PaRIS–EHIS

**Versión:** 0.2<br>
**Fecha:** 2026-08-21<br>
**Estado:** síntesis documental cerrada; la clasificación asistida permanece
pendiente de confirmación por el investigador.

## Alcance y procedimiento

Esta revisión narrativa se realizó para fundamentar el protocolo de
armonización retrospectiva entre PaRIS Cycle 1 y EHIS Wave 3. Se ejecutaron en
PubMed tres búsquedas sobre métodos generales, equivalencia de medida y
aplicaciones PaRIS/EHIS. Se recuperaron 813 registros únicos; 121 fueron
priorizados mediante reglas transparentes y revisados posteriormente por título
y resumen. Se clasificaron 35 como evidencia directamente relevante, 29 como
antecedentes y 57 como no pertinentes. Entre los incluidos se identificaron 15
documentos nucleares, 10 aplicaciones útiles y 10 métodos especializados.

La revisión es deliberadamente narrativa. No pretende exhaustividad ni realiza
una evaluación formal del riesgo de sesgo. Las búsquedas, resultados y
propuestas de decisión están versionados. `screening.csv` reserva campos
separados para la ratificación del investigador y evita presentar la selección
asistida como una selección humana definitiva.

## 1. La armonización es un proceso dirigido por preguntas y objetivos

La guía de [Maelstrom Research](https://pubmed.ncbi.nlm.nih.gov/27272186/)
sitúa la definición de la pregunta y las variables objetivo antes de evaluar
qué puede aportar cada estudio. BioSHaRE mostró una implementación en la que se
definieron 96 objetivos comunes, se evaluó el potencial de cada cohorte y se
programaron algoritmos específicos para transformar las fuentes al formato
objetivo ([Doiron et al.](https://pubmed.ncbi.nlm.nih.gov/24257327/)). MINDMAP
aplicó el mismo principio mediante un `DataSchema` común
([Hofer et al.](https://pubmed.ncbi.nlm.nih.gov/33184054/)).

Para PaRIS–EHIS esto implica que ninguna encuesta debe convertirse
automáticamente en patrón oro. Cada `target_variable` debe tener una definición,
un universo y una representación propios; después se evaluará de forma
independiente si PaRIS y EHIS pueden generarla.

## 2. La semejanza nominal es insuficiente

La literatura distingue armonización sintáctica, semántica y estadística. El
glosario de equivalencia en salud poblacional subraya que pueden existir sesgos
por diferencias en constructos, grupos, contextos y procedimientos incluso
cuando las etiquetas coinciden
([Morris](https://pubmed.ncbi.nlm.nih.gov/29511034/)). Los trabajos de
armonización preestadística muestran discrepancias en redacción, dirección,
cuantificación, administración, codificación y missingness entre ítems que
parecían medir el mismo atributo
([pre-statistical harmonization](https://pubmed.ncbi.nlm.nih.gov/34689753/)).

El assessment del proyecto debe mantener separadas al menos siete dimensiones:
concepto, medida, universo, tiempo, representación, derivación y administración.
La clasificación global `DIRECT`–`NONE` resumirá la decisión, pero no sustituirá
el perfil dimensional ni su justificación.

## 3. Variables observables y constructos latentes requieren métodos distintos

La revisión reciente de métodos estadísticos distingue procedimientos basados
en distribuciones, proportion scores y modelos de variable latente, y señala
que la elección depende de la escala original y de si el objetivo es observable
o latente ([Zhang et al.](https://pubmed.ncbi.nlm.nih.gov/42207414/)). Para edad,
sexo, diagnósticos o utilización, el método preferente será una transformación
determinista y auditable. No se justificará un modelo latente cuando una
recodificación conceptual es suficiente.

En escalas y PROMs/PREMs, una métrica común puede construirse mediante IRT,
equipercentile linking u otros modelos, pero solo bajo diseños identificables.
Los ejemplos revisados utilizan ítems compartidos, instrumentos administrados
a una misma muestra o anclajes defendibles. La comparación de métodos de
depresión advierte que el éxito para un constructo no garantiza éxito para otro
([Data Harmonization in Aging Research](https://pubmed.ncbi.nlm.nih.gov/26524232/)).

Por tanto, los métodos psicométricos se reservarán para variables con:

1. constructo común suficientemente definido;
2. ítems comunes, muestra puente u otro anclaje justificable;
3. evidencia de unidimensionalidad y funcionamiento comparable;
4. análisis de invariancia o differential item functioning;
5. sensibilidad a los supuestos del enlace.

## 4. Población, modo y contexto forman parte de la comparabilidad

EHIS representa población general de 15 años o más en hogares privados, mientras
que PaRIS se dirige principalmente a personas de 45 años o más con contacto
reciente con atención primaria. La restricción por edad no reproduce por sí sola
el proceso de selección de PaRIS. El proyecto debe construir escenarios
poblacionales progresivos y describir qué componentes de elegibilidad no pueden
reproducirse.

La evidencia EHIS muestra además que el modo de administración puede afectar
las medias latentes incluso cuando se sostiene la invariancia de medida para
determinadas escalas ([estudio de modo en EHIS 3](https://pubmed.ncbi.nlm.nih.gov/35618987/)).
Las comparaciones entre encuestas europeas también pueden cambiar según la
fuente elegida, tanto en prevalencias de cuidados informales
([Verbakel et al.](https://pubmed.ncbi.nlm.nih.gov/33352669/)) como en
desigualdades de discapacidad
([Berger et al.](https://pubmed.ncbi.nlm.nih.gov/30478617/)). Esto justifica
registrar encuesta, país, modo, periodo, filtros y diseño como parte de la
interpretación, no como simples covariables administrativas.

## 5. PaRIS requiere conservar su arquitectura conceptual propia

El framework PaRIS fue desarrollado mediante revisión de modelos, participación
de expertos y pacientes, y organiza resultados, experiencias, capacidades,
conductas, condiciones crónicas y características del sistema
([Valderas et al.](https://pubmed.ncbi.nlm.nih.gov/39174334/)). Ese diseño está
orientado al desempeño de la atención primaria para personas con condiciones
crónicas y no coincide con la finalidad poblacional general de EHIS.

El artículo de desarrollo del cuestionario PaRIS y la experiencia de campo en
Eslovenia deben utilizarse para interpretar selección de instrumentos,
traducción, administración y factibilidad, no para asumir que un dominio PaRIS
tiene necesariamente un equivalente EHIS. Los PREMs específicos de atención
primaria probablemente quedarán como `RELATED` o `NONE`; la falta de equivalente
será un resultado sustantivo.

## 6. Metadatos, procedencia y revisión humana

Los enfoques basados en metadatos pueden mejorar descubrimiento, normalización
y reutilización, pero la heterogeneidad de modelos y terminologías continúa
siendo una limitación
([scoping review](https://pubmed.ncbi.nlm.nih.gov/38354027/)). En este proyecto,
DDI aporta la separación entre concepto, universo y representación; Maelstrom
aporta el flujo source-to-target. La combinación se implementará mediante
catálogos versionados, mappings explícitos y algoritmos independientes para
cada encuesta.

La automatización semántica se limitará a generar candidatos. La aceptación
requiere revisar pregunta, instrucciones, universo, periodo, categorías,
missingness, derivación y notas nacionales. También se registrarán desacuerdos
y decisiones negativas.

## 7. Consecuencias para la validación

La validación debe acumular evidencia sin convertir ninguna comprobación en un
patrón oro aislado:

- revisión de contenido frente a cuestionarios y manuales;
- revisión independiente de mappings críticos;
- tests de los algoritmos con casos sintéticos y extremos;
- frecuencias, rangos, missingness y trazabilidad del registro fuente;
- coherencia interna con variables relacionadas;
- evaluación por país, modo y escenario poblacional;
- análisis de sensibilidad a recodificaciones y puntos de corte;
- invariancia, DIF o linking solo para escalas con diseño defendible;
- análisis ponderado respetando el diseño de cada encuesta.

La similitud de distribuciones será evidencia de plausibilidad, no demostración
de equivalencia. Una diferencia puede reflejar población, periodo o sistema
sanitario; una similitud puede ocultar sesgos compensatorios.

## 8. Framework resultante

La revisión respalda el siguiente flujo:

`research question -> target concept -> target universe -> target
representation -> source assessment -> harmonisation class -> source-specific
algorithm -> quality control -> sensitivity -> validated output`

Cada assessment conservará las siete dimensiones de compatibilidad. La clase
global será `DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED` o `NONE`,
con un estado independiente de revisión. Los métodos estadísticos complejos no
elevarán una relación conceptualmente débil a armonización válida.

## 9. Prioridades derivadas para el piloto

Se propone comenzar con:

1. edad y sexo, como controles de transformación y población;
2. salud autopercibida, por su aparente sencillez y sensibilidad a categorías;
3. diabetes, para estudiar formulación diagnóstica y horizonte temporal;
4. utilización sanitaria, para estudiar referencia temporal y denominadores;
5. PHQ-8 u otra escala realmente compartida, para probar invariancia y reglas de
   puntuación;
6. un PREM PaRIS sin equivalente directo, para validar `RELATED`/`NONE`.

Este conjunto prueba tanto el éxito como los límites del framework y evita que
el piloto se seleccione únicamente entre variables fáciles.

## Limitaciones de la revisión

La búsqueda reproducible se concentró en PubMed; las consultas preparadas para
Scopus y Web of Science no se ejecutaron por requerir acceso institucional. La
selección fue intencional y no permite estimar exhaustividad. La extracción
estructurada de las 15 fuentes nucleares se utilizó para la síntesis temática,
pero las decisiones de cribado siguen identificadas como propuestas hasta que
el investigador complete los campos correspondientes en `screening.csv`.

## Conclusión

La evidencia disponible apoya una armonización retrospectiva dirigida por
variables objetivo, multidimensional, iterativa y completamente trazable. Para
PaRIS y EHIS, el principal riesgo no es técnico sino inferencial: declarar
equivalentes variables que comparten una etiqueta pero difieren en constructo,
población o medición. La infraestructura debe facilitar transformaciones
reproducibles y, con igual importancia, documentar por qué determinadas
variables no deben compararse.
