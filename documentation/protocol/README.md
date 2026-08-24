# Protocolo

## Documento canónico

- `protocol.md`: protocolo científico vigente. Corresponde a la propuesta v0.2
  de réplica y robustez tras el informe OECD 2026.
- `../../website/protocolo.qmd`: proyección pública en Quarto. Debe resumir el
  protocolo canónico, pero no sustituirlo.

## Fuentes

`sources/` contiene únicamente documentos que pueden versionarse y su
trazabilidad:

- `oecd-2026-comparison.pdf`: benchmark público bajo CC BY 4.0;
- `oecd-2026-comparison-assessment.md`: evaluación metodológica e implicaciones;
- `manifest.csv`: DOI, fecha, licencia, hash y estado de ingesta.

## Archivo

`archive/` conserva versiones sustituidas. `protocol-v0.1.md` documenta el
alcance de armonización general anterior a OECD 2026 y no guía nuevos análisis.

## Versionado

Una modificación sustantiva debe actualizar `config/project.yml`,
`harmonisation/decisions/decision_log.csv`, `CHANGELOG.md` y la proyección
Quarto. Antes de iniciar análisis empíricos, la versión aprobada debe fecharse y
congelarse con su commit.
