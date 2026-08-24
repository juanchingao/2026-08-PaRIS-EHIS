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

## Próximo bloque

Los scripts del nuevo protocolo comenzarán en `22_` para preservar el historial.
El primer candidato será un inventario de viabilidad de archivos, países,
variables de diseño e indicadores, pero no debe implementarse hasta que JALR
confirme el alcance v0.2.
