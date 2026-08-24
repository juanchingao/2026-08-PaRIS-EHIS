# Gobernanza del cribado con dos investigadores y un agente automático

> **Estado desde 2026-08-24: en pausa.** La arquitectura y las decisiones se
> conservan, pero no se iniciarán R2 ni la corrida LLM hasta que JALR confirme
> el alcance del protocolo v0.2.

## Unidad y decisiones

La unidad es la referencia bibliográfica deduplicada. Los valores permitidos
son `INCLUDE`, `BACKGROUND` y `EXCLUDE`. Cada exclusión debe poder acompañarse
de un motivo controlado; las notas libres son complementarias.

## Dos investigadores

Los revisores `R1` y `R2` trabajan de forma independiente. La interfaz oculta
la decisión ajena hasta que ambos hayan cerrado el registro. Después se deriva:

- acuerdo exacto: decisión consensuada;
- desacuerdo `INCLUDE`/`BACKGROUND`: discusión o adjudicación;
- cualquier desacuerdo con `EXCLUDE`: adjudicación obligatoria.

Se informarán acuerdo porcentual y kappa de Cohen, pero kappa no sustituye la
inspección de los patrones de desacuerdo ni la justificación científica.

El acceso al área privada se realizará mediante Cloudflare Access con una lista
de correos concretos y códigos de un solo uso. D1 conservará identidad, versión
de la decisión y fecha; la autenticación no se implementará dentro de la
aplicación.

## Tercer agente automático

Para el corpus actual, la tercera columna será una propuesta LLM independiente
con `multiprompt screening`: se evalúa por separado cada criterio de inclusión y
exclusión, se usa salida JSON validada y se registra versión/hash del prompt,
modelo, criterio, input y commit. El agente recibe exclusivamente título,
resumen cuando exista, base y etapa; nunca recibe decisiones JALR/R2,
prioridades ni propuestas previas. Su salida se congela antes de revelar las
decisiones humanas y nunca adjudica ni excluye automáticamente.

ASReview con active learning y, para registros multilingües, `ELAS-lang`, se
mantienen como análisis separado para priorizar actualizaciones futuras. No se
presentarán como tercer revisor independiente cuando hayan sido entrenados o
ajustados con decisiones JALR del mismo corpus.

Los registros con solo título se identifican explícitamente. En ellos el agente
solo propone `EXCLUDE` cuando la irrelevancia es clara; la ausencia de resumen no
es un criterio de exclusión y la incertidumbre obliga a marcar revisión humana.

## Evaluación prospectiva

La referencia será el consenso/adjudicación humana. Antes de usar un agente en
una actualización futura se estimarán, como mínimo:

- sensibilidad y especificidad;
- valor predictivo negativo;
- falsos negativos por motivo de inclusión;
- rendimiento separado en registros con y sin resumen;
- rendimiento por idioma y base de datos;
- carga ahorrada a sensibilidades objetivo del 95%, 99% y 100%;
- calibración de probabilidades cuando el modelo las proporcione.

No se fijará un umbral de exclusión automática con los mismos datos usados para
entrenar o seleccionar el modelo. Se reservará una partición de evaluación o se
utilizará validación temporal en una actualización bibliográfica posterior.

## Transparencia web

La web pública puede mostrar estrategias exactas, citas regeneradas desde
fuentes públicas, decisiones finales y métricas agregadas. Las decisiones por
revisor, abstracts licenciados y discrepancias sin resolver pertenecen al área
privada hasta aprobar expresamente su publicación.
