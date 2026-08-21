# Hoja de ruta para retomar el proyecto

**Actualizada:** 2026-08-21<br>
**Estado:** pendiente<br>
**Punto de partida:** metadatos PaRIS/EHIS extraídos y síntesis narrativa v0.2;
clasificación bibliográfica pendiente de ratificación del investigador

## Objetivo de la siguiente etapa

Pasar del framework conceptual a un piloto source-to-target pequeño y
auditable. El piloto debe comprobar tanto casos armonizables como límites de
comparabilidad antes de extender el trabajo al inventario completo.

Antes del piloto, el investigador debe completar en
`research/narrative-review/screening.csv` la decisión, iniciales y fecha de los
121 registros. Esta ratificación no cambia la síntesis documental, pero es
necesaria para presentar las cifras de selección como definitivas.

## Paso 1. Operacionalizar la compatibilidad

Definir valores controlados para:

- `concept_compatibility`;
- `measure_compatibility`;
- `population_compatibility`;
- `time_compatibility`;
- `representation_compatibility`;
- `derivation_compatibility`;
- `administration_compatibility`.

Propuesta inicial: `EXACT`, `COMPATIBLE`, `PARTIAL`, `INCOMPATIBLE`, `UNKNOWN`
y `NOT_APPLICABLE`. Deben documentarse las reglas que convierten el perfil
dimensional en `DIRECT`, `RECODABLE`, `DERIVABLE`, `PARTIAL`, `RELATED` o
`NONE`. No automatizar la clase global hasta revisar el piloto.

**Terminado cuando:** los vocabularios, definiciones, ejemplos y combinaciones
prohibidas estén documentados y validados mediante tests.

## Paso 2. Construir el catálogo conceptual piloto

Crear solamente los dominios, conceptos, medidas y universos necesarios para
los casos piloto. Distinguir siempre concepto, instrumento, ítem, variable
fuente y variable derivada.

**Terminado cuando:** cada variable fuente piloto pueda enlazarse sin ambigüedad
a un concepto, una medida y un universo versionados.

## Paso 3. Seleccionar y documentar los casos piloto

| Caso | Función metodológica |
|---|---|
| Edad | Bandas, top-coding, población y anonimización |
| Sexo/género | Diferencias conceptuales y de categorías |
| Salud autopercibida | Recodificación ordinal y dirección de escala |
| Diabetes | Diagnóstico, horizonte temporal y filtros |
| Utilización sanitaria | Periodo, denominador y contacto asistencial |
| PHQ-8 u otra escala compartida | Scoring, missingness e invariancia |
| PREM exclusivo de PaRIS | Control negativo `RELATED`/`NONE` |

Para cada caso, extraer pregunta, instrucciones, universo, filtros, periodo,
categorías, missingness, derivación y notas nacionales. Confirmar primero que
la escala elegida existe realmente y es utilizable en ambas fuentes.

**Terminado cuando:** existe una ficha comparativa revisable por cada caso.

## Paso 4. Definir variables objetivo independientes

Especificar por objetivo:

- identificador y etiqueta;
- concepto y definición;
- universo;
- periodo de referencia;
- tipo y representación;
- política de ausencia;
- usos permitidos y límites interpretativos.

No adoptar automáticamente la definición de PaRIS o EHIS. Si un concepto exige
dos horizontes incompatibles, crear dos objetivos o concluir que no existe un
objetivo común válido.

**Terminado cuando:** los objetivos pueden evaluarse sin consultar todavía los
valores observados en los microdatos.

## Paso 5. Evaluar mappings y registrar decisiones

Crear una fila source-to-target por encuesta y objetivo. Completar las siete
dimensiones, clase global, estado, justificación y evidencia documental.
Justificación obligatoria para `PARTIAL`, `RELATED`, `NONE` y `UNKNOWN`.

Los mappings críticos deberían contar con segunda revisión. Registrar
discrepancias y consenso en el decision log.

**Terminado cuando:** cada objetivo piloto tiene una decisión explícita para
PaRIS y EHIS, incluyendo decisiones negativas.

## Paso 6. Implementar algoritmos por fuente

Desarrollar por separado:

```text
PaRIS source -> target variable
EHIS source  -> target variable
```

Cada algoritmo debe declarar entradas, categorías esperadas, política de
missingness, salida y versión; fallar ante códigos desconocidos; conservar
trazabilidad; y disponer de tests sintéticos con casos normales y extremos.

**Terminado cuando:** los algoritmos piloto pasan tests sin necesitar los
microdatos originales.

## Paso 7. Incorporar microdatos de forma controlada

Cuando estén disponibles en `data/raw`:

1. revisar licencia, almacenamiento y disclosure;
2. inventariar archivos, versión, tamaño y hash;
3. comprobar nombres, tipos y códigos frente al diccionario;
4. identificar pesos, estratos, PSU y diseño de varianza;
5. registrar divergencias nacionales;
6. mantener los originales inmutables y fuera de Git.

**Terminado cuando:** existe un informe de ingestión sin modificar los archivos
fuente y se conocen las limitaciones de análisis por país.

## Paso 8. Validación empírica y sensibilidad

Aplicar los algoritmos y evaluar rangos, frecuencias, missingness, denominadores,
coherencia interna, países y trazabilidad. Comparar:

1. poblaciones originales;
2. restricción común por edad;
3. aproximación al contacto con atención primaria;
4. máxima población común reproducible.

Usar pesos y diseño complejo cuando estén disponibles. La similitud de
distribuciones será control de plausibilidad, no prueba de equivalencia.

Para escalas, considerar invariancia, DIF o linking únicamente si hay anclaje
metodológicamente defendible.

**Terminado cuando:** cada objetivo piloto tiene resultados de calidad,
sensibilidad y una decisión revisada sobre su uso comparativo.

## Paso 9. Cerrar la versión 0.2

Actualizar protocolo, modelo, catálogos, mappings, algoritmos, revisión
narrativa y limitaciones. Congelar versiones de datos, mappings y código
utilizadas en el piloto.

## Archivos de reentrada

- `documentation/protocol/protocol-v0.1.md`
- `research/narrative-review/narrative-review-v0.1.md`
- `research/narrative-review/evidence-map.csv`
- `data/metadata/paris_cycle1_puf_dictionary.csv`
- `data/metadata/ehis_wave3_anonymisation_dictionary.csv`
- `harmonisation/mappings/source_to_target.csv`
- `harmonisation/catalogues/target_variables.csv`
- `harmonisation/decisions/decision_log.csv`

## Precauciones

- No mapear por nombre o similitud textual sin revisar el significado.
- No colapsar códigos de ausencia heterogéneos.
- No confundir equivalencia de medida con igualdad de distribuciones.
- No mezclar la definición de variables con ponderación o estimación.
- No subir microdatos, derivados individuales ni documentación restringida.
