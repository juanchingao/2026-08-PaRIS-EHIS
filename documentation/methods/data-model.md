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
poblacional, temporal, de representación, derivación y administración.

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

Los identificadores serán estables y únicos. Patrones recomendados: `DOM-####`,
`CON-####`, `MEA-####`, `SRC-####`, `TGT-####`, `MAP-####`, `ALG-####` y
`DEC-####`.
