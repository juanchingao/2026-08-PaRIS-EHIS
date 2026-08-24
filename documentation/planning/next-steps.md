# Hoja de ruta para retomar el proyecto

**Actualizada:** 2026-08-24

**Estado:** reorientación científica; alcance anterior en pausa

**Punto de reentrada:** confirmar el protocolo v0.2 antes de analizar microdatos

## Cambio que obliga a replantear el proyecto

El 15 de julio de 2026, OECD publicó *Comparing patient-reported outcome and
experience measures in international health surveys* (DOI
[`10.1787/acf46da9-en`](https://doi.org/10.1787/acf46da9-en)). El informe ya
realiza la comparación general PaRIS–EHIS prevista originalmente: mapea
dominios, cruza ítems, armoniza respuestas, restringe poblaciones y
postestratifica resultados.

No se continuará la armonización amplia como si este informe no existiera. La
contribución recomendada pasa a ser una réplica independiente y un análisis de
robustez de las comparaciones PaRIS–EHIS, inicialmente para salud autopercibida
y hospitalización.

Documentos de reentrada:

- `documentation/protocol/protocol.md`;
- `documentation/protocol/sources/oecd-2026-comparison-assessment.md`;
- `documentation/protocol/sources/manifest.csv`;
- `website/protocolo.qmd`.

## Trabajo conservado pero suspendido

Los siguientes artefactos no se eliminan y continúan siendo trazables:

- corpus de 1.076 referencias únicas con decisiones JALR;
- búsquedas PubMed, Scopus y Embase y sus resúmenes;
- interfaz privada, D1 y control de acceso;
- contrato y lote local del tercer revisor LLM;
- metadatos normalizados PaRIS/EHIS;
- modelo dimensional, clases y reglas de seguridad.

Hasta nueva decisión no se ejecutarán R2, la corrida LLM, la ampliación masiva
del mapping ni cambios funcionales de la web de cribado.

## Fase 0. Confirmar la contribución

Decidir formalmente si el objetivo principal será:

> Reproducir las comparaciones PaRIS–EHIS publicadas por OECD (2026) y evaluar
> su sensibilidad a decisiones de medición, población, ponderación, diseño y
> missingness.

La propuesta no es buscar una estimación «correcta» única, sino distinguir
resultados robustos, sensibles, no evaluables y discrepantes.

**Terminado cuando:** JALR aprueba el título, la pregunta principal, los dos
indicadores primarios y el carácter confirmatorio de la réplica.

## Fase 1. Inventario de viabilidad

Crear una matriz país–fuente con:

- versión y licencia de PaRIS PUF y EHIS Wave 3;
- disponibilidad de los trece países candidatos;
- variables de salud autopercibida, hospitalización, cronicidad y contacto;
- edad, sexo y variables de elegibilidad;
- peso final, estrato, PSU y práctica PaRIS;
- códigos de ausencia y desviaciones nacionales;
- tamaño y hash de cada archivo.

No incorporar ficheros a `data/raw` hasta revisar licencia y almacenamiento.

**Terminado cuando:** se conoce qué comparaciones son legal y técnicamente
reproducibles y cuáles quedarían `NOT_ASSESSABLE`.

## Fase 2. Especificación de réplica OECD

Reconstruir, sin consultar resultados propios:

1. definiciones exactas de los dos indicadores;
2. población original de cada encuesta;
3. edad de 45 o más años;
4. definición de enfermedad crónica;
5. definición de contacto sanitario reciente;
6. países y exclusiones;
7. ponderación original y postestratificación;
8. estándar demográfico;
9. missingness y denominadores;
10. estimación de varianza.

Registrar explícitamente las ambigüedades del informe: cuatro frente a ocho
celdas edad-sexo, *top-two* frente a *top-three-box*, combinación de pesos,
selección de indicadores y ausencia de código público identificado.

**Terminado cuando:** existe una especificación congelada, ejecutable y revisada.

## Fase 3. Solicitar aclaraciones y materiales

Preparar una consulta breve a los autores u OECD solicitando, si pueden
compartirse:

- código o pseudocódigo;
- variables y versiones de los conjuntos;
- definiciones de cronicidad y contacto;
- construcción de pesos y celdas;
- reglas de missingness;
- tablas numéricas detrás de las figuras.

La falta de respuesta no bloqueará una réplica parcial, pero impedirá etiquetar
como `DISCREPANT` lo que solo sea `NOT_ASSESSABLE`.

**Terminado cuando:** se archiva la respuesta o se documenta la fecha límite sin
respuesta.

## Fase 4. Assessment preestadístico

Para cada indicador y encuesta completar las siete dimensiones:

- concepto;
- medida;
- población;
- periodo;
- representación;
- derivación;
- administración.

Definir las variables objetivo independientemente y asignar clase `DIRECT`,
`RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED` o `NONE`. La segunda persona
investigadora revisará los mappings primarios.

**Terminado cuando:** ninguna regla depende de la distribución observada.

## Fase 5. Algoritmos y tests sintéticos

Implementar por separado:

```text
PaRIS source -> population funnel -> target indicator -> survey estimate
EHIS source  -> population funnel -> target indicator -> survey estimate
```

Los tests cubrirán categorías válidas, códigos desconocidos, no aplicable,
ausencia, fronteras de edad, cronicidad, contacto, pesos, celdas vacías y
trazabilidad.

**Terminado cuando:** los algoritmos pasan sin usar microdatos reales.

## Fase 6. Congelar el plan estadístico

Preespecificar:

- estimando principal y tolerancia de réplica;
- poblaciones del embudo;
- codificaciones ordinales y binarias;
- estándar PaRIS y estándares de sensibilidad;
- incorporación del diseño complejo;
- tratamiento de missingness;
- exclusiones de países;
- cuadrícula multiespecificación;
- clases `REPRODUCED`, `APPROXIMATELY_REPRODUCED`, `SENSITIVE`,
  `NOT_ASSESSABLE` y `DISCREPANT`.

**Terminado cuando:** el plan tiene fecha, hash y aprobación antes de generar
estimaciones del resultado.

## Fase 7. Réplica y robustez

Ejecutar por este orden:

1. control de ingestión y flujo de participantes;
2. estimaciones con diseño original;
3. réplica de la especificación OECD;
4. sensibilidades preespecificadas;
5. revisión de discrepancias;
6. control de disclosure;
7. síntesis y discusión.

La similitud con las cifras OECD no validará por sí sola el mapping. Una
diferencia residual tampoco se atribuirá automáticamente al sistema sanitario.

## Indicadores adicionales

Tabaquismo, alcohol, fruta, verdura y acceso solo se evaluarán después de cerrar
los dos indicadores primarios. Serán exploratorios salvo enmienda prospectiva.
Los PREMs PaRIS sin equivalente EHIS se conservarán como controles negativos.

## Decisiones inmediatas de JALR

1. Aprobar o modificar el alcance de réplica y robustez.
2. Confirmar salud autopercibida y hospitalización como indicadores primarios.
3. Decidir si se intentarán los trece países o un subconjunto predefinido.
4. Confirmar qué microdatos y variables de diseño están disponibles.
5. Autorizar la preparación de la consulta metodológica a OECD.

No se reanudará ningún flujo suspendido hasta resolver la primera decisión.
