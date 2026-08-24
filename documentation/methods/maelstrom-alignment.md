# Alineación del proyecto con las guías Maelstrom Research

## Decisión de diseño

Maelstrom Research se adopta como guía de proceso para la armonización
retrospectiva. No se adopta como una equivalencia terminológica automática: las
clases y dimensiones específicas de PaRIS–EHIS permanecen explícitas y
versionadas.

## Correspondencia operativa

| Maelstrom | Implementación PaRIS–EHIS | Producto canónico |
|---|---|---|
| Paso 0. Preguntas, objetivos y protocolo | Objetivo, alcance, usos permitidos y límites | `documentation/protocol/` |
| Paso 1. Información y selección de estudios | Inventario de PaRIS/EHIS, diseño, población, documentación y licencias | `data/metadata/source_manifest.csv` |
| Paso 2. DataSchema y potencial de armonización | Variables objetivo y assessment multidimensional | `harmonisation/catalogues/target_variables.csv`, `harmonisation/mappings/source_to_target.csv` |
| Paso 3. Procesamiento | Algoritmos independientes PaRIS/EHIS | `harmonisation/algorithms/` y `R/` |
| Paso 4. Calidad | Tests, diseño muestral, missingness, sensibilidad y validación | `tests/`, `outputs/` y `logs/` |
| Paso 5. Difusión y preservación | Documentación versionada, web pública y outputs aprobados | `website/`, `reports/`, `CHANGELOG.md` |

## DataSchema y modelo mínimo

La variable objetivo equivale funcionalmente a una variable del DataSchema,
pero su definición debe preceder a la asignación de variables fuente. El modelo
se mantiene:

`domain -> concept -> measure -> source_variable -> assessment -> target_variable -> algorithm -> harmonised_variable`

El assessment conserva por separado concepto, medida, población/universo,
periodo, representación, derivación y administración. Las clases globales
`DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED` y `NONE` no se infieren
de forma mecánica a partir de semejanzas de nombre o distribución.

## Adaptaciones necesarias

- PaRIS y EHIS son encuestas complejas; pesos, estratos y conglomerados forman
  parte de la evaluación y del procesamiento.
- Los códigos de ausencia estructural, no aplicable, rechazo, desconocido y no
  recogido permanecen separados.
- La armonización conceptual se cierra antes de consultar distribuciones de
  microdatos.
- La web publica documentación y resultados agregados, nunca materiales cuya
  licencia o disclosure no estén resueltos.
