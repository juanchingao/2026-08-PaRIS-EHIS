# Revisión metodológica multibase

> **Estado:** en pausa desde 2026-08-24. No iniciar R2, ejecutar el lote LLM ni
> ampliar el corpus mientras no se confirme el protocolo v0.2.

## Archivos canónicos

| Archivo | Función |
|---|---|
| `protocol.md` | Protocolo de la revisión metodológica, suspendido |
| `search-strategies.csv` | Estrategias exactas y fechas |
| `screening.csv` | Decisiones PubMed ratificadas por JALR |
| `evidence-map.csv` | Clasificación de evidencia |
| `evidence-extraction.csv` | Extracción estructurada de fuentes nucleares |
| `core-sources.csv` | Registro conciso de fuentes nucleares |

## Artefactos operativos

- `exports/`: resultados públicos/agregados versionables; las exportaciones
  completas y RIS permanecen ignorados.
- `screening-review.html`: aplicación autocontenida del cribado PubMed.
- `supplementary-screening-review.html`: aplicación local ignorada para el
  cribado suplementario.
- `ai-screening/`: contrato y esquema del tercer revisor, sin resultados.
- `archive/`: síntesis y revisión narrativa anteriores a la reorientación.

Los scripts `04`–`12` reconstruyen este flujo. Los scripts `16`–`21` preparan la
interfaz privada y el agente; todos están en pausa salvo mantenimiento explícito.
