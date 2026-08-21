# Changelog

## [Unreleased]

### Added

- Script reproducible para contar, recuperar y comparar con PubMed las tres
  búsquedas equivalentes de Scopus mediante `scopusflow`; su ejecución queda
  pendiente hasta que el entorno permita cargar la dependencia `curl`.

- Cierre documental de la revisión narrativa v0.2, con síntesis consolidada,
  limitaciones explícitas y un registro canónico que separa las propuestas de
  cribado asistido de su confirmación por el investigador.
- Interfaz HTML autocontenida para revisar los 121 registros, guardar el
  progreso en el navegador, actualizar la matriz con autorización explícita y
  recordar el archivo autorizado para actualizaciones posteriores, además de
  exportar copias de las decisiones confirmadas a CSV.

- Primer borrador de la introducción del manuscrito en Quarto, revisado para
  incorporar precedentes de armonización y comparaciones entre encuestas
  identificados en la revisión narrativa, los dominios del piloto y evidencia
  específica sobre salud autopercibida, diabetes y métodos estadísticos, con
  bibliografía reproducible y formatos HTML, DOCX y PDF.

- Borrador v0.1 del protocolo para evaluación ética, incluyendo uso secundario,
  acceso, minimización, seguridad, disclosure, conservación y dispensa de
  consentimiento pendiente de valoración institucional.
- Versión Quarto autocontenida y preparada para impresión del protocolo ético.

- Hoja de ruta de reentrada con los pasos, criterios de finalización y piloto
  propuesto para pasar del framework conceptual a mappings validados.
- Estado actual y prioridades de la próxima sesión incorporados a `AGENTS.md`.

- Protocolo de revisión narrativa metodológica, estrategias reproducibles para
  PubMed y plantillas de selección y extracción.
- Flujo en R basado en NCBI E-utilities para recuperar, normalizar y deduplicar
  bibliografía metodológica.
- Ranking transparente de candidatos sin decisiones automáticas y primera
  síntesis de implicaciones metodológicas para PaRIS–EHIS.
- Revisión por título y resumen de 121 candidatos, con clasificación inicial
  reproducible y pendiente de confirmación por el investigador.
- Mapa temático de los 35 registros incluidos, extracción estructurada de 15
  fuentes nucleares y revisión narrativa metodológica v0.1.

- Estructura inicial portable para Windows y RStudio Server en Ubuntu.
- Separación entre datos fuente, armonización y capa analítica.
- Protocolo v0.1, instrucciones para agentes y modelo de metadatos.
- Plantillas para búsqueda metodológica, fuentes y cribado.
- Catálogos iniciales, configuración de rutas y validación del entorno R.
- Plantillas de conceptos, medidas, universos y variables fuente.
- Subdirectorios persistentes por encuesta y ruta `interim` configurable.
- Protección de microdatos y resultados generados mediante `.gitignore`.
- Política de finales de línea portable entre Windows y Ubuntu.
- Extracción reproducible de 151 variables EHIS Wave 2 y 154 de Wave 3 desde
  los documentos de reglas de anonimización.
- Comparación inicial de presencia entre olas y registro SHA-256 de las fuentes.
- Extracción reproducible del codebook PaRIS Cycle 1: 195 variables y 1.302
  combinaciones valor–código, con reglas de ausencia y notas nacionales.
