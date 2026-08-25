# Alineación del proyecto con las guías Maelstrom Research

## Decisión de diseño

Maelstrom Research se adopta como guía principal de proceso para la
armonización retrospectiva. No se adopta como una equivalencia terminológica
automática: las clases y dimensiones específicas del proyecto permanecen
explícitas y versionadas.

## Correspondencia operativa

| Maelstrom | Implementación del proyecto | Producto canónico |
|---|---|---|
| Paso 0. Preguntas, objetivos y protocolo | Objetivo, alcance, usos permitidos y límites | `documentation/protocol/` |
| Paso 1. Información y selección de estudios | Inventario multifuente, diseño, población, documentación y licencias | `documentation/inventories/survey-inventory.csv`, `data/metadata/source_manifest.csv` |
| Paso 2. DataSchema y potencial de armonización | Variables objetivo y assessment multidimensional | `harmonisation/catalogues/target_variables.csv`, `harmonisation/mappings/source_to_target.csv` |
| Paso 3. Procesamiento | Algoritmos independientes por encuesta | `harmonisation/algorithms/` y `R/` |
| Paso 4. Calidad | Tests, diseño muestral, missingness, sensibilidad y validación | `tests/`, `outputs/` y `logs/` |
| Paso 5. Difusión y preservación | Documentación versionada, web pública y outputs aprobados | `website/`, `reports/`, `CHANGELOG.md` |

## DataSchema y modelo mínimo

La variable objetivo equivale funcionalmente a una variable del DataSchema,
pero su definición debe preceder a la asignación de variables fuente. El modelo
se mantiene:

`domain -> concept -> measure -> source_variable -> assessment -> target_variable -> algorithm -> harmonised_variable`

El assessment conserva como núcleo concepto, medida, población/universo,
periodo, representación, derivación y administración. Se registran además
redacción, filtros, contexto del cuestionario, adaptaciones nacionales y pérdida
de información.

Las clases técnicas `DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED` y
`NONE` no se infieren de forma mecánica a partir de semejanzas de nombre o
distribución. El potencial científico se comunica por separado como
`IDENTICAL`, `COMPATIBLE`, `PARTIALLY_COMPATIBLE`, `INCOMPATIBLE` o
`UNAVAILABLE`; esta es una taxonomía operativa del proyecto, no una atribución
literal a Maelstrom.

## Adaptaciones necesarias

- PaRIS y sus comparadores son encuestas complejas; pesos, estratos,
  conglomerados y niveles adicionales forman parte del assessment y del
  procesamiento.
- Los códigos de ausencia estructural, no aplicable, rechazo, desconocido y no
  recogido permanecen separados.
- La armonización conceptual se cierra antes de consultar distribuciones de
  microdatos.
- Los análisis se estiman primero dentro de encuesta y país. Una estructura
  común de datos no convierte las fuentes en una única muestra.
- La web publica documentación y resultados agregados, nunca materiales cuya
  licencia o disclosure no estén resueltos.
- La escalabilidad se demuestra primero con el piloto PaRIS–EHIS. SHARE e IHP
  solo se incorporan tras superar puertas de viabilidad y calidad; el resto de
  encuestas requiere una pregunta de validación o extensión explícita.
