# Changelog

## [Unreleased]

### Added

- Pipeline reproducible de la scoping review con tres líneas independientes
  (armonización explícita, comparabilidad de medidas y marcos operativos),
  traducciones específicas para cinco bases, estados versionados y formulario
  PRESS.
- Ejecuciones completas y paginadas de PubMed y Scopus para las líneas A/B/C,
  con respuestas brutas inmutables fuera de Git, manifiestos, checksums,
  partición temporal verificable y conservación de identificadores de origen.
- Esquema bibliográfico común, importadores para RIS/BibTeX/CSV/NBIB,
  normalización y deduplicación conservadora en tablas de obras, registros,
  procedencias muchos-a-muchos y coincidencias aproximadas pendientes.
- Conjunto de referencias semilla y validación real en PubMed y Scopus,
  registros de literatura gris y rastreo de citas, resumen PRISMA y muestra
  ciega para el pilotaje humano de sensibilidad y precisión.

- Protocolo v0.3 para desarrollar y evaluar un framework multifuente de
  armonización retrospectiva, con PaRIS como encuesta índice, EHIS como primer
  comparador y ampliaciones condicionadas a puertas de viabilidad y calidad.
- Work Package 1 de scoping review conforme a JBI y PRISMA-ScR, con protocolo,
  auditoría de búsquedas históricas, cobertura conceptual, estrategias ampliadas
  no ejecutadas, artículos centinela y plantilla de extracción.
- Inventario inicial de diez encuestas por nivel, matriz de preguntas y
  objetivos, cronograma por Work Packages, registro de riesgos y plantillas
  auditables de DataSchema y equivalencia.
- Vocabulario controlado de potencial de armonización: `IDENTICAL`,
  `COMPATIBLE`, `PARTIALLY_COMPATIBLE`, `INCOMPATIBLE` y `UNAVAILABLE`, separado
  de la clase técnica de transformación.
- Protocolo v0.2 de reorientación hacia una réplica independiente y análisis de
  robustez de la comparación PaRIS–EHIS publicada por OECD en julio de 2026,
  con estimandos, embudo poblacional, diseño complejo, missingness, sensibilidad
  multiespecificación y clasificación prospectiva de reproducibilidad.
- Ingesta trazable del policy paper OECD `10.1787/acf46da9-en`: PDF CC BY 4.0,
  manifiesto con SHA-256, extracción local no versionada, evaluación crítica y
  registro como fuente nuclear del proyecto.

- Preparación reproducible del tercer revisor LLM para los 1.076 registros
  efectivos: criterios multiprompt versionados, esquema JSON estricto, lote
  local para Responses/Batch, manifiesto con hashes y adaptadores separados para
  envío, descarga y precarga en D1. El input excluye decisiones humanas y exige
  autorización explícita antes de transferir contenido restringido.
- Puesto de cribado privado en la página de referencias: carga de abstracts bajo
  demanda, filtro por estado de la revisión propia, decisión y motivo
  controlados, notas opcionales y guardado versionado sin sobrescribir el
  historial. La propuesta automática y la revisión del otro investigador siguen
  ocultas hasta completar ambas revisiones humanas.
- Activación de Cloudflare Access OTP para la API privada, restringida a JALR
  e investigador 2 mediante allowlist exacta, con entrada y cierre de sesión
  desde la página de referencias y verificación JWT en el Worker.
- Arquitectura web híbrida: se conserva el diseño HTML/CSS editorial de la
  landing, el catálogo independiente adopta la misma estética con filtros y
  paginación, y únicamente el protocolo se renderiza con Quarto. El protocolo
  no incluye resultados y mantiene bibliografía, estrategias exactas,
  resaltados y anotaciones Hypothesis.
- Carga privada reproducible en D1 de 1.091 filas bibliográficas (1.076
  efectivas), 1.091 decisiones JALR y 891 propuestas automáticas. Los revisores
  JALR e investigador 2 se gestionan mediante una configuración local editable
  y excluida de Git.
- Primer sitio público estático preparado para Cloudflare Pages, con panel de
  avance, flujo bibliográfico agregado, metodología, salvaguardas y hoja de
  ruta. El generador publica únicamente recuentos agregados y excluye microdatos,
  abstracts licenciados y documentación restringida.
- Publicación web de las diez estrategias exactas registradas y de 121
  referencias PubMed con DOI/PMID, sin decisiones para preservar el cegamiento.
  Se mantiene fuera
  del despliegue público el detalle procedente exclusivamente de exportaciones
  Scopus/Embase hasta resolver su licencia de redistribución.
- Diseño de doble revisión cegada y adjudicación mediante Cloudflare Access OTP,
  allowlist de correos, Worker y D1, junto con tablas separadas para evaluaciones
  automáticas reproducibles.
- Correspondencia explícita entre las seis etapas de las guías Maelstrom y el
  modelo, carpetas y productos canónicos de PaRIS–EHIS.
- Sección pública de protocolo con objetivo, fuentes, assessment dimensional,
  clases, evidencia, piloto, validación, seguridad y alineación Maelstrom.
- Despliegue del panel público como Worker Static Assets en la cuenta
  `paris-ehis` y creación de la base D1 privada `paris-ehis-review` en región
  europea, con tablas para revisores, registros, decisiones, adjudicación y
  evaluaciones automáticas.

- Importación reproducible de exportaciones RIS de Embase, manifiesto de lotes,
  deduplicación interna y comparación por PMID, DOI y título contra PubMed y
  Scopus: 879 registros Embase únicos y 235 nuevos frente a ambas bases.
- Priorización transparente de los 970 candidatos suplementarios y aplicación
  HTML independiente para su cribado, sin convertir puntuaciones automáticas en
  decisiones bibliográficas.

- Configuración reproducible de la búsqueda en Scopus, con `scopusflow`
  declarado como dependencia opcional y credenciales documentadas solo mediante
  variables de entorno excluidas de Git. Las estrategias refinadas recuperaron
  1.178 registros Scopus únicos; 443 coincidieron con PubMed y 735 quedaron como
  candidatos nuevos pendientes de cribado.

### Changed

- Reformulada la réplica OECD como benchmark y piloto PaRIS–EHIS dentro del
  framework v0.3, en lugar de objetivo exclusivo del proyecto. El protocolo
  v0.2 se archiva con trazabilidad.
- Ampliado el modelo de assessment para registrar redacción, filtros, contexto
  del cuestionario, adaptaciones nacionales y pérdida de información, sin
  abandonar las siete dimensiones mínimas anteriores.
- Reclasificado el corpus multibase anterior como búsqueda piloto: sus 1.076
  decisiones se conservan, pero no se transfieren automáticamente a la nueva
  scoping review.
- Reorganizado el repositorio sin renumerar el pipeline: el protocolo vigente
  utiliza `documentation/protocol/protocol.md`, las versiones sustituidas y los
  scaffolds iniciales se archivan, y se añaden índices para documentación,
  investigación y scripts.
- Trasladadas a `data/raw/documentation/` las fuentes PaRIS/EHIS cuya licencia
  de redistribución no está confirmada. Los scripts `02` y `03` leen ahora esos
  originales ignorados e inmutables; sus hashes y derivados versionables se
  mantienen en `data/metadata/`.
- Normalizados los nombres del inventario de países y de la fuente pública OECD,
  que queda acompañada por manifiesto y evaluación en
  `documentation/protocol/sources/`.
- Puestos en pausa R2, la corrida del tercer revisor LLM, la ampliación masiva
  del mapping y los cambios de la web de cribado. El objetivo general de
  armonización se conserva como antecedente, pero no guiará nuevos análisis
  mientras se confirma la reorientación.
- Actualizados la página Quarto del protocolo, la hoja de ruta y el estado del
  proyecto para distinguir benchmark OECD, réplica, sensibilidades y análisis
  exploratorios.

- Finalizado el cribado suplementario de 955 referencias únicas: 68 `INCLUDE`,
  332 `BACKGROUND` y 555 `EXCLUDE`. El cribado combinado contiene 1.076
  referencias únicas y 103 inclusiones para la siguiente fase de síntesis.

- Revisados los duplicados del cribado suplementario: 14 grupos, 29 filas
  implicadas y 15 copias marcadas como `EXCLUDE` con enlace al registro
  conservado. El corpus efectivo queda en 955 referencias; el conflicto de
  decisión PHQ-9 se resolvió conservando el registro Embase con resumen.

- Ratificadas 618 decisiones suplementarias con iniciales `JALR`: 64
  `INCLUDE`, 329 `BACKGROUND` y 225 `EXCLUDE`. Incluyen las 418 propuestas
  `LOW` de confianza alta confirmadas por el investigador. Quedan sin decisión
  352 propuestas `EXCLUDE` de confianza baja para revisión rápida.

- Ratificación por el investigador de los 121 registros del cribado narrativo:
  35 `INCLUDE`, 29 `BACKGROUND` y 57 `EXCLUDE`.

- Script reproducible para contar, recuperar y comparar con PubMed las tres
  búsquedas equivalentes de Scopus mediante `scopusflow`.

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
