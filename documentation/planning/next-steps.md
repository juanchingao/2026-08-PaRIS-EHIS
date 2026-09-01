# Hoja de ruta para retomar el proyecto

**Actualizada:** 2026-09-01
**Estado:** protocolo v0.3 multifuente propuesto; pregunta WP1 en redefinición
**Punto de reentrada:** reformulación y aprobación científica de la pregunta
antes de congelar y ejecutar la búsqueda definitiva de WP1

## Identidad y dominio

`ALIGN Health` queda adoptado como nombre de trabajo actual, con el descriptor
`Health survey harmonisation for policy`. La web utiliza esta identidad desde
el 2026-09-01. Su carácter de nombre de trabajo no autoriza a renombrar
repositorio, paquetes, identificadores, DOI, citas, metadatos históricos ni
URLs técnicas.

La elección, registro y migración a un dominio propio se posponen hasta una
decisión específica posterior. Mientras tanto se conservan las rutas y dominios
técnicos existentes.

## Contribución propuesta

El proyecto desarrollará y evaluará un framework reproducible de armonización
retrospectiva con PaRIS como encuesta índice. EHIS será el primer comparador y
el piloto mínimo viable. La réplica OECD de salud autopercibida y
hospitalización se conserva como benchmark dentro del piloto, pero ya no define
por sí sola el objetivo general.

SHARE e IHP solo se evaluarán tras completar el piloto. CCHS, EU-SILC, MEPS,
HRS, BRFSS y PVS requieren una pregunta específica de validación o extensión.

## Decisión 0. Aprobar el protocolo v0.3

JALR debe aprobar o modificar:

1. la pregunta metodológica principal;
2. los tres niveles de pregunta;
3. PaRIS como índice y EHIS como primer comparador;
4. la estructura de encuestas por niveles;
5. WP1 como scoping review sistemática;
6. el enfoque de producto mínimo viable;
7. los resultados metodológicos coprimarios.

Hasta entonces, las decisiones `DEC-2026-003` a `DEC-2026-009` permanecen
`PROPOSED`.

## Siguiente bloque A. Congelar WP1

1. Revisar el protocolo en `research/scoping-review/protocol.md`.
2. Incorporar a Alicia Serrano Vedruna como segunda investigadora y completar
   con ella la revisión independiente.
3. Elegir plataforma de registro.
4. Validar las estrategias ampliadas por base.
5. Definir y probar el conjunto de artículos centinela.
6. Retirar o justificar topes y orden por relevancia.
7. Pilotar `extraction-template.csv` por dos personas.

Las ejecuciones v0.2 de PubMed y Scopus y sus 98.260 trabajos deduplicados se
conservan como evidencia de viabilidad y para informar la redefinición. No se
cribarán como corpus definitivo ni se ampliarán a Web of Science hasta congelar
la pregunta y versionar nuevas estrategias. Web of Science Starter está
operativo con la credencial institucional SERMAS desde la verificación del
2026-09-01.

**Terminado cuando:** protocolo y estrategias tienen versión, fecha, hash,
aprobación y registro anterior a la nueva búsqueda.

## Siguiente bloque B. Inventario de viabilidad del núcleo

Completar para PaRIS y EHIS:

- archivos disponibles y hashes;
- países, periodo, versión y licencia;
- cuestionario, diccionario y metodología;
- variables de edad, residencia, cronicidad y contacto;
- peso, estrato, PSU y niveles adicionales;
- códigos de ausencia y adaptaciones nacionales;
- reglas de disclosure y ubicación autorizada.

La matriz de partida está en
`documentation/inventories/survey-inventory.csv`. No se incorporarán microdatos
nuevos a `data/raw` sin revisión legal y técnica.

**Terminado cuando:** cada requisito del núcleo es `AVAILABLE`, `UNAVAILABLE` o
`UNRESOLVED` con evidencia; no quedan supuestos implícitos.

## Siguiente bloque C. DataSchema mínimo viable

1. Seleccionar una muestra pequeña de dominios y usos analíticos.
2. Definir variables objetivo antes de consultar nombres fuente.
3. Completar población, periodo, categorías, ausencia y pérdida tolerable.
4. Asignar variables fuente PaRIS y EHIS.
5. Realizar assessments independientes en doce dimensiones.
6. Adjudicar discrepancias y congelar versión.

Salud autopercibida y hospitalización se mantendrán por su función de benchmark.
La composición adicional del piloto queda pendiente; no se ampliará a las 349
variables normalizadas.

**Terminado cuando:** cada variable tiene definición, uso permitido, potencial,
rationale, dos revisiones y estado.

## Siguiente bloque D. Algoritmos sintéticos

Implementar por separado:

```text
PaRIS source -> eligibility -> target variable -> survey estimate
EHIS source  -> eligibility -> target variable -> survey estimate
```

Los tests cubrirán categorías válidas, filtros, códigos no sustantivos,
fronteras de edad, periodos, pérdida, pesos, celdas vacías y procedencia.

**Terminado cuando:** los algoritmos pasan sin leer microdatos reales.

## Siguiente bloque E. Piloto y transportabilidad

1. Estimar dentro de cada encuesta y país con su diseño.
2. Describir cobertura, missingness y distribuciones.
3. Aplicar el embudo poblacional.
4. Estandarizar solo por variables realmente comunes.
5. Cuantificar el efecto encuesta y la diferencia residual.
6. Comparar asociaciones nomológicas preespecificadas.
7. Ejecutar sensibilidades y evaluar el benchmark OECD.

**Terminado cuando:** existe un informe de comparabilidad que separa generación,
equivalencia y comportamiento empírico.

## Puerta de ampliación

Solo después del informe del piloto se decidirá:

- incorporar SHARE para dominios de salud, funcionamiento y envejecimiento;
- incorporar IHP para PREMs y atención primaria;
- seleccionar una extensión externa concreta;
- preparar una pregunta sustantiva sobre atención primaria, multimorbilidad y
  desigualdades.

## Trabajo conservado sin ejecución automática

- 1.076 referencias cribadas y decisiones JALR;
- búsquedas PubMed, Scopus y Embase;
- D1, interfaz privada y acceso OTP;
- contrato del revisor LLM;
- metadatos normalizados PaRIS/EHIS;
- protocolo v0.2 de réplica OECD archivado.

Estos artefactos se reutilizarán cuando sean compatibles con v0.3. No se
reanudarán R2, LLM, mapping masivo ni ampliaciones de la web por defecto.

## Archivos de control

- Protocolo: `documentation/protocol/protocol.md`.
- Preguntas: `documentation/planning/research-questions.csv`.
- Cronograma: `documentation/planning/work-packages.csv`.
- Riesgos: `documentation/planning/risk-register.csv`.
- Inventario: `documentation/inventories/survey-inventory.csv`.
- Decisiones: `harmonisation/decisions/decision_log.csv`.
