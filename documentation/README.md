# Documentación del proyecto

Este directorio separa documentos científicos vigentes, métodos, planificación,
inventarios y versiones históricas. El punto de entrada operativo del proyecto
es `planning/next-steps.md`.

| Área | Contenido | Estado |
|---|---|---|
| `protocol/` | Protocolo científico canónico, fuentes y versiones anteriores | Activo; v0.3 pendiente de aprobación |
| `methods/` | Modelo de datos y decisiones metodológicas reutilizables | Activo |
| `planning/` | Próximos pasos y planes de productos | Activo; web funcional en pausa |
| `inventories/` | Inventarios de encuestas y fuentes no individuales | Activo; viabilidad pendiente |
| `ethics/` | Documentación para evaluación ética | Borrador histórico |

Los documentos fuente PaRIS/EHIS cuya licencia de redistribución no está
confirmada se conservan localmente en `data/raw/documentation/`, fuera de Git.
Los derivados y sus hashes permanecen en `data/metadata/`.

## Convención

- El archivo sin sufijo de versión es la versión canónica vigente.
- Las versiones sustituidas se mueven a `archive/` y no se editan salvo para
  corregir enlaces o advertencias de estado.
- Los documentos públicos con licencia compatible se guardan junto a un
  manifiesto y una evaluación de ingesta.
- Ningún PDF o libro nuevo se versionará sin comprobar procedencia, licencia y
  ausencia de información restringida.
