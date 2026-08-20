# Reports

Informes reproducibles de exploración, inventario, armonización y validación.
Deben cargar `scripts/00_setup.R` y no incorporar registros individuales ni
resultados que vulneren disclosure.

## Protocolo ético

`ethics-protocol.qmd` genera una versión HTML autocontenida del protocolo para
el Comité de Ética. Se renderiza desde la raíz del proyecto con:

```bash
quarto render reports/ethics-protocol.qmd
```
