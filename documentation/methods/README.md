# Métodos

| Documento | Función |
|---|---|
| `data-model.md` | Modelo mínimo y trazabilidad source-to-target |
| `maelstrom-alignment.md` | Correspondencia con las etapas Maelstrom |
| `ehis-anonymisation-processing.md` | Extracción reproducible de reglas EHIS |
| `paris-codebook-processing.md` | Extracción reproducible del codebook PaRIS |
| `screening-governance.md` | Doble revisión y agente automático, actualmente en pausa |

Los originales PaRIS/EHIS se encuentran en `data/raw/documentation/{paris,ehis}`
y no se versionan mientras su licencia de redistribución no esté confirmada.
Los scripts `02` y `03` leen desde esa ubicación mediante `project_paths$raw`.
