# Mapa de scripts

Todos los scripts R se ejecutan desde la raíz y comienzan con
`source("scripts/00_setup.R")`. La numeración expresa el orden histórico; no se
renumera para evitar romper documentación y ejecuciones reproducibles.

| Rango | Flujo | Estado |
|---|---|---|
| `00`–`01` | Configuración y validación del entorno | Activo |
| `02`–`03` | Extracción de documentación EHIS y PaRIS | Activo |
| `04`–`12` | Búsqueda, cribado y evidencia multibase | En pausa |
| `13` | Regeneración de datos públicos de la web | Mantenimiento |
| `14` | No asignado; hueco histórico intencional | Reservado |
| `15` | Render Quarto de la web | Mantenimiento |
| `16`–`18` | D1, importación y Cloudflare Access | En pausa |
| `19`–`21` | Preparación, ejecución e importación del revisor LLM | En pausa |
| `22`–`31` | Scoping review: búsquedas A/B/C, corpus, semillas y PRISMA | Activo |

## Scoping review metodológica

Los scripts `22_`–`30_` implementan el pipeline bibliográfico vigente. Las
respuestas brutas e intermedias se mantienen fuera de Git; los manifiestos,
recuentos, checksums y decisiones se versionan en
`research/scoping-review/`. El bloque no lee microdatos de PaRIS ni EHIS.
