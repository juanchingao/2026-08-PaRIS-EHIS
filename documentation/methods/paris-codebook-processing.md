# Procesamiento del diccionario y codebook PaRIS Cycle 1

## Documento fuente

`data/raw/documentation/paris/paris-cycle1-puf-codebook-202605-v0.xlsx`

El archivo se registra mediante SHA-256 en `data/metadata/source_manifest.csv`.
La procedencia se atribuye a OECD por el contenido del documento, pero la
licencia y URL de procedencia deben verificarse antes de redistribuirlo. El
original se mantiene en `data/raw`, inmutable y excluido de Git.

## Estructura del libro

| Hoja | Dimensión utilizada | Contenido |
|---|---:|---|
| `PUF_DataDictionary` | 196 filas de datos, incluida una fila de sección | Definición y estadísticas de las variables del PUF |
| `PUF_MSPatient Codebook` | 1.688 filas de datos | Categorías, códigos, notas nacionales y observaciones |

La fila “Recoded and composite variables” es un encabezado de sección y no se
incluye como variable.

## Extracción reproducible

`scripts/03_extract_paris_codebook.R` lee directamente el OOXML sin modificar
ni reexportar el libro original. Genera:

- `paris_cycle1_puf_dictionary.csv`: una fila por variable;
- `paris_cycle1_puf_value_labels.csv`: tabla larga valor–código;
- `paris_cycle1_codebook_only_variables.csv`: control de variables presentes
  solo en el codebook.

## Resultado inicial

| Resultado | Recuento |
|---|---:|
| Variables reales | 195 |
| Filas valor–código | 1.302 |
| Variables enlazadas entre ambas hojas | 195 |
| Variables presentes solo en el codebook | 0 |
| Variables con notas específicas de país | 43 |
| Filas identificadas como categorías de ausencia | 492 |

Los registros se marcan como `EXTRACTED_UNREVIEWED`: la correspondencia entre
las hojas ha sido comprobada, pero los contenidos aún requieren revisión
metodológica antes de asignar conceptos o mappings con EHIS.

## Contenido preservado

Para cada variable se conserva:

- población o filtro de aplicación;
- tipo de variable;
- etiqueta o texto descriptivo;
- representación compacta de valores y códigos;
- número y porcentaje de ausentes observados;
- número de valores distintos, mínimo, máximo y ejemplo;
- categorías y códigos en formato largo;
- notas específicas por país;
- observaciones del codebook;
- hoja y fila de procedencia.

## Convenciones de ausencia

El codebook utiliza varias familias de valores ausentes:

- `-97`: normalmente `Not answered`;
- `-96`: normalmente `Multiple answers`;
- `-95`: normalmente `Question not asked`;
- missing extendidos como `.a`, `.d`, `.b` o `.b/.c`;
- categorías positivas etiquetadas `NA`, cuyo código varía según la variable;
- códigos específicos para `Don't know`.

Por ello, los ausentes deben transformarse mediante
`paris_cycle1_puf_value_labels.csv` a nivel de variable. No debe usarse una
única lista global de códigos.

## Observaciones metodológicas iniciales

1. El archivo se denomina `combined_15COU`, y `Country` tiene 15 valores
   distintos observados, aunque su catálogo contiene 19 países posibles. El
   diccionario por sí solo no identifica de manera inequívoca qué 15 están en
   el extracto.
2. Hay 43 variables con excepciones nacionales: variables retiradas de ciertos
   PUF, recodificaciones por disclosure, opciones no disponibles y diferencias
   de formulación.
3. Las estadísticas `missing_n`, `missing_pct`, `distinct_n`, `min` y `max`
   describen este PUF combinado; no son propiedades conceptuales estables.
4. Las variables derivadas y compuestas deben distinguirse de los ítems fuente
   antes de armonizar con EHIS.
5. El identificador estable usa `SRC-PARIS-C1-<NOMBRE_NORMALIZADO>`, conservando
   además el nombre original con su capitalización.

## Próximos pasos

- Clasificar las 195 variables por dominio, concepto, medida e instrumento.
- Normalizar las 43 notas nacionales en una tabla país–variable–regla.
- Identificar variables fuente, escalas y variables derivadas o compuestas.
- Seleccionar candidatos PaRIS para los 154 registros EHIS Wave 3.
- Revisar primero salud general, cronicidad, funcionamiento, salud mental,
  utilización sanitaria, edad, sexo y determinantes de salud.
