# Síntesis metodológica preliminar

**Estado:** borrador de trabajo basado en las fuentes nucleares; requiere
cribado humano y ampliación temática.

## Cribado inicial de candidatos

Se revisaron por título y resumen los 121 candidatos priorizados. La primera
clasificación, pendiente de confirmación por el investigador, contiene 35
registros `INCLUDE`, 29 `BACKGROUND` y 57 `EXCLUDE`. Todos disponían de resumen.
La clasificación completa y sus motivos se conservan en
`reviewed-screening.csv`; ninguna decisión procede solo de la puntuación de
relevancia.

## Decisiones provisionales para PaRIS–EHIS

1. **Definir primero la variable objetivo.** El objetivo común no será una
   copia de una variable de PaRIS o EHIS. Para cada encuesta se evaluará de
   manera independiente si sus fuentes permiten generarlo.
2. **Separar las dimensiones de compatibilidad.** Concepto, medida, universo,
   referencia temporal, representación, derivación y administración se
   registrarán por separado. Una coincidencia nominal no compensa una
   incompatibilidad en otra dimensión.
3. **Distinguir variables observables y constructos latentes.** Las
   recodificaciones deterministas serán el método preferente para variables
   directamente observables. Las escalas, PROMs y PREMs solo se enlazarán
   estadísticamente si existe solapamiento conceptual, evidencia psicométrica y
   un diseño identificable (ítems comunes, muestra puente o supuestos fuertes).
4. **No usar igualdad distributiva como validación.** Distribuciones parecidas
   son control de plausibilidad, no prueba de equivalencia. Diferencias reales
   de población, periodo y sistema sanitario pueden persistir tras armonizar.
5. **Tratar la población como parte del significado.** Se compararán escenarios
   escalonados: poblaciones originales, restricción por edad, aproximación al
   contacto con atención primaria y máxima población común reproducible.
6. **Separar armonización y estimación.** Pesos, estratos, conglomerados y
   estimación de varianza se documentarán después de definir la variable, sin
   confundir diseño muestral con equivalencia semántica.
7. **Conservar procedencia y decisiones negativas.** Cada variable armonizada
   debe enlazar fuente, versión, mapping, algoritmo y commit. `PARTIAL`,
   `RELATED` y `NONE` son resultados válidos y no fallos del proceso.
8. **Automatización solo como generación de candidatos.** Similitud textual,
   embeddings o modelos de lenguaje podrán priorizar pares, pero la aceptación
   exige revisión del cuestionario, universo, códigos y documentación nacional.

## Aplicación inmediata

El piloto debería comenzar con edad, sexo, salud autopercibida, diabetes y una
medida de utilización sanitaria. Este conjunto cubre variables sencillas y
otras con diferencias previsibles de formulación, referencia y población. Un
PROM o PREM complejo se añadirá después para probar explícitamente el límite
entre `PARTIAL`, `RELATED` y una armonización psicométrica defendible.

## Cuestiones todavía abiertas

- Definición operativa y puntuación de cada dimensión de compatibilidad.
- Umbral para aceptar una pérdida de información como `RECODABLE`.
- Necesidad y disponibilidad de doble revisión independiente.
- Instrumentos concretos compartidos por ambas encuestas y licencias asociadas.
- Componentes de diseño disponibles por país en los microdatos accesibles.
- Métodos empíricos aplicables cuando no existen ítems comunes ni muestra puente.
