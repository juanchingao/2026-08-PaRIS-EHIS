# Modelo de datos para la armonización

Una variable fuente implementa un concepto para un universo y una
representación determinados. Compartir concepto no implica compartir medida ni
ser armonizable.

## Entidades

- `domain`: área general de conocimiento.
- `concept`: constructo abstracto.
- `measure`: pregunta, escala, instrumento o definición operacional.
- `universe`: población a la que la medida es aplicable.
- `source_variable`: variable concreta de encuesta, ola y país.
- `target_variable`: especificación común independiente de ambas fuentes.
- `assessment`: evaluación multidimensional source-to-target.
- `algorithm`: transformación versionada específica de cada fuente.
- `harmonised_variable`: salida de un algoritmo validado.

Cada mapping valora por separado compatibilidad conceptual, de medida,
redacción, población, periodo, filtros, representación, derivación,
administración, contexto del cuestionario, adaptaciones nacionales y pérdida de
información. Las siete dimensiones originales siguen siendo el núcleo mínimo;
las dimensiones adicionales impiden ocultar diferencias relevantes dentro de
una categoría genérica.

| Clase | Interpretación |
|---|---|
| `DIRECT` | Generación directa sin pérdida relevante |
| `RECODABLE` | Recodificación determinista |
| `DERIVABLE` | Combinación o algoritmo explícito |
| `PARTIAL` | Solapamiento insuficiente para intercambiabilidad |
| `RELATED` | Relación teórica, constructo o medida diferente |
| `NONE` | Información insuficiente |

La certeza se registra por separado como `PROPOSED`, `REVIEWED`, `VALIDATED`,
`REJECTED` o `UNRESOLVED`.

## Potencial frente a transformación

La clase técnica y el potencial científico son campos distintos:

- `harmonisation_class` describe cómo se produciría la salida: `DIRECT`,
  `RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED` o `NONE`;
- `harmonisation_potential` resume si la fuente es `IDENTICAL`, `COMPATIBLE`,
  `PARTIALLY_COMPATIBLE`, `INCOMPATIBLE` o `UNAVAILABLE` para una variable y un
  uso concretos.

Una recodificación determinista no garantiza compatibilidad. Del mismo modo,
`UNAVAILABLE` significa que la fuente no permite construir la variable, no que
la encuesta sea de baja calidad.

## Procedencia mínima de una salida

Toda variable armonizada debe conservar encuesta, país, ola o año, versión de
origen, algoritmo, assessment, peso, estrato, conglomerado y grado de
armonización cuando esos campos existan y puedan usarse legalmente. Las bases
pueden procesarse con un esquema común, pero nunca pierden su procedencia ni se
tratan como una única muestra.

Los identificadores serán estables y únicos. Patrones recomendados: `DOM-####`,
`CON-####`, `MEA-####`, `SRC-####`, `TGT-####`, `MAP-####`, `ALG-####` y
`DEC-####`.
