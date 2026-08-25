# Ingesta y evaluación del informe OCDE 2026

> **Interpretación actualizada en protocolo v0.3:** la evaluación factual del
> informe se mantiene. La recomendación inicial de convertir la réplica OECD en
> todo el proyecto fue sustituida por un framework multifuente. La réplica
> PaRIS–EHIS se conserva como benchmark y piloto metodológico.

## Identificación y trazabilidad

| Campo | Valor |
|---|---|
| Título | *Comparing patient-reported outcome and experience measures in international health surveys* |
| Autor institucional | OECD |
| Autores declarados | Candan Kendir, Isaura Gutiérrez Vargas y Nicolas Larrain |
| Tipo | Policy paper |
| Publicación | 15 de julio de 2026 |
| Editorial | OECD Publishing, Paris |
| DOI | [10.1787/acf46da9-en](https://doi.org/10.1787/acf46da9-en) |
| Extensión | 39 páginas |
| Licencia | Creative Commons Attribution 4.0 International (CC BY 4.0) |
| Archivo local | `documentation/protocol/sources/oecd-2026-comparison.pdf` |
| SHA-256 | `BF3A255F5286A89F46DDD6AF4FEA32C4EBC98B061451AC54B8BF0D5E0262B0A9` |
| Fecha de ingesta | 24 de agosto de 2026 |
| Estado | Fuente nuclear; desencadena reorientación del protocolo |

El PDF original se conserva sin modificaciones. El texto extraído para análisis
se almacena en `data/interim/protocol/` y permanece fuera de Git.

## Alcance del informe

El informe compara PaRIS Cycle 1, EHIS Wave 3, la International Health Policy
Survey, la People's Voice Survey y SHARE. Combina dos componentes:

1. comparación de finalidad, población objetivo, muestreo, modo de recogida,
   periodo de campo, tamaño muestral, respuesta y orientación conceptual;
2. comparación de indicadores mediante mapeo de dominios, crosswalk manual de
   ítems y armonización de categorías de respuesta.

PaRIS actúa como marco de referencia. Las preguntas de las otras encuestas se
asignan manualmente al subdominio PaRIS más próximo; cada pregunta recibe un
único subdominio y los ítems multiconcepto se clasifican por su constructo
dominante. El informe identifica 16 preguntas comparables y selecciona cuatro
indicadores para el análisis empírico: salud general autopercibida, calidad de
la atención experimentada, confianza para el autocuidado y hospitalización.

Para PaRIS–EHIS, la comparación empírica detallada se concentra en salud
autopercibida y hospitalización. Incluye trece países coincidentes y restringe
el análisis armonizado a personas de 45 o más años con enfermedades crónicas y
contacto sanitario reciente. Los resultados se estandarizan por edad y sexo a
una distribución de referencia basada en los objetivos de diseño de PaRIS.

## Hallazgos que cambian el proyecto

- Las encuestas son complementarias, no intercambiables. EHIS describe salud,
  determinantes, utilización y desigualdades en población general; PaRIS se
  centra en personas usuarias de atención primaria, especialmente con
  enfermedades crónicas, y enlaza pacientes con características de la práctica.
- El solapamiento real es pequeño. Los PROMs se aproximan sobre todo entre
  PaRIS, EHIS y SHARE; los PREMs entre PaRIS, IHP y PVS.
- Igualar edad, cronicidad, contacto sanitario y distribución demográfica no
  elimina las diferencias. En algunos países incluso cambia su dirección.
- Recodificar escalas no demuestra equivalencia. En salud autopercibida, la
  escala PaRIS `excellent`–`poor` y la escala EHIS `very good`–`very bad` tienen
  anclajes y puntos medios psicológicos diferentes.
- La finalidad, la población, el marco muestral, el modo, el periodo y la
  estructura del diseño forman parte del estimando; no son simples covariables
  que puedan neutralizarse por completo.

Estos resultados invalidan la premisa de novedad del protocolo anterior: ya
existe una comparación oficial PaRIS–EHIS con armonización conceptual y
empírica. Repetir una armonización general sin una pregunta adicional produciría
una contribución redundante.

## Información metodológica que debe aclararse o someterse a sensibilidad

El informe es suficientemente detallado para definir un benchmark, pero no para
reconstruir sin ambigüedad todos los análisis a partir del texto público. La
nueva investigación debe distinguir entre ausencia de detalle en el informe y
error metodológico. Los principales puntos a aclarar son:

- nombres de variables, versiones exactas de ficheros y código de análisis;
- definición operacional común de enfermedad crónica y contacto sanitario
  reciente;
- tratamiento de no respuesta por ítem y códigos `not sure`/no aplicable;
- combinación de pesos originales con los nuevos pesos de postestratificación;
- incorporación de estratos, conglomerados, práctica PaRIS y métodos de varianza;
- referencia a una estructura de «cuatro celdas» al combinar cuatro bandas de
  edad con dos categorías de sexo, que conceptualmente produciría ocho celdas;
- regla de dicotomización descrita como selección de las dos opciones más
  favorables y también como enfoque *top-three-box*, mientras las tablas aplican
  distintos números de categorías positivas según la encuesta;
- criterios de selección de los cuatro indicadores entre los 16 candidatos;
- incertidumbre de las estimaciones y sensibilidad a puntos de corte alternativos;
- desfase temporal, modo de administración y particularidades nacionales.

Estos puntos se registran como preguntas reproducibles, no como conclusiones
sobre la validez del trabajo de la OCDE.

## Consecuencia científica evaluada inicialmente

La primera reorientación recomendó un estudio metodológico de réplica y robustez
con tres capas:

1. **Reconstrucción:** reproducir tan fielmente como permitan la documentación y
   los microdatos las comparaciones PaRIS–EHIS publicadas para salud
   autopercibida y hospitalización.
2. **Auditoría de decisiones:** explicitar qué parte de cada contraste depende
   del concepto, el ítem, la población, el periodo, la representación, la
   derivación, la administración o el diseño muestral.
3. **Análisis de sensibilidad:** evaluar poblaciones, recodificaciones,
   estándares demográficos, ponderaciones, missingness y especificaciones
   alternativas predefinidas. Solo después se considerará ampliar indicadores.

Estas capas se mantienen en el piloto PaRIS–EHIS. En v0.3 el producto principal
es el framework reproducible —DataSchema, assessment, algoritmos y evaluación de
transportabilidad— y la réplica OECD es uno de sus casos de validación.

## Elementos del trabajo anterior que se conservan

- metadatos normalizados y trazabilidad de variables;
- separación de siete dimensiones de compatibilidad;
- clases `DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED` y `NONE`;
- definición independiente de variables objetivo;
- algoritmos separados por fuente y pruebas sintéticas;
- tratamiento explícito del diseño complejo y de los tipos de ausencia;
- corpus bibliográfico y decisiones JALR como recurso secundario.

Quedan en pausa la corrida del tercer revisor LLM, la ampliación masiva del
mapping y cualquier análisis de microdatos anterior a la aprobación de v0.3. La
revisión bibliográfica se reformula prospectivamente como scoping review WP1.

## Decisiones actuales que requieren confirmación

1. Aprobar el framework multifuente v0.3 y su producto mínimo PaRIS–EHIS.
2. Confirmar qué parte de la réplica OECD se usará como benchmark del piloto.
3. Decidir los países del piloto solo después del inventario de acceso y diseño.
4. Confirmar el acceso efectivo a microdatos y variables de diseño.
5. Valorar una solicitud a OECD de código, definiciones y tablas numéricas.
6. Congelar el DataSchema mínimo viable antes de ampliar indicadores o fuentes.
