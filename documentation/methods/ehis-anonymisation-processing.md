# Procesamiento de las reglas de anonimización EHIS

## Documentos fuente

- `data/raw/documentation/ehis/ehis-wave2-anonymisation-rules.pdf`
- `data/raw/documentation/ehis/ehis-wave3-anonymisation-rules.docx`

Ambos documentos se registran mediante SHA-256 en
`data/metadata/source_manifest.csv`. La procedencia y licencia exactas quedan
pendientes de verificación antes de redistribuir los originales. Por esa razón
se mantienen en `data/raw`, que es inmutable y está excluido de Git.

## Extracción reproducible

El script `scripts/02_extract_ehis_anonymisation.R` genera:

- `ehis_wave2_anonymisation_dictionary.csv`: extracción por coordenadas de
  palabras del PDF;
- `ehis_wave3_anonymisation_dictionary.csv`: extracción de la cuadrícula OOXML
  del DOCX, incluidas filas de continuación;
- `ehis_anonymisation_dictionary.csv`: catálogo conjunto con identificadores
  estables por ola;
- `ehis_wave2_wave3_variable_comparison.csv`: comparación de presencia y texto.

Todos los registros se marcan inicialmente como `EXTRACTED_UNREVIEWED`. La
extracción automática preserva el texto, pero no equivale a revisión
metodológica ni valida una correspondencia.

## Resultado inicial

| Resultado | Número de variables |
|---|---:|
| EHIS Wave 2 | 151 |
| EHIS Wave 3 | 154 |
| Presentes en ambas olas | 131 |
| Solo Wave 2 | 20 |
| Solo Wave 3 | 23 |

Variables identificadas solo en Wave 2: `FV1`–`FV4`, desagregaciones de tamaño
del hogar por edad, `HH_ACT`, `HH_INACT`, `HO1`–`HO4`, `MARSTADEFACTO`, `PSU`,
`REFMONTH` y `REFYEAR`.

Variables identificadas solo en Wave 3: `BIRTHPLACEFATH`, `BIRTHPLACEMOTH`,
`BMI`, `CD1P`, `CD2`, `DH1`–`DH6`, `HHNBPERS_0_13`, `HO12`, `HO34`, `PARTNERS`,
`PE9`, `PL8`, `PL9`, `REFDATE`, `SK5`, `SK6`, `SU` y `WGT_SPEC`.

Estas listas describen los documentos de anonimización, no necesariamente todo
el contenido de los cuestionarios ni de cada fichero nacional.

## Reglas de anonimización detectadas

La búsqueda textual inicial encuentra reglas de eliminación, agrupación,
top-coding y excepciones nacionales. Una misma variable puede pertenecer a más
de una categoría, por lo que los recuentos no son mutuamente excluyentes.

| Patrón textual | Wave 2 | Wave 3 |
|---|---:|---:|
| `removed` | 22 | 21 |
| `unaltered` | 129 | 118 |
| agrupación/reagrupación | 8 | 9 |
| top-coding | 17 | 10 |
| regla específica de país | 40 | 36 |

## Precauciones de interpretación

1. Estos documentos describen la representación anonimizada difundida. No
   sustituyen al cuestionario, manual metodológico o variables de transmisión.
2. Una variable eliminada o agrupada puede conservar una versión más detallada
   en microdatos con otro régimen de acceso.
3. La comparación marca diferencias **textuales**. PDF y DOCX codifican las
   tablas de forma distinta; por ello, `*_text_differs` no significa por sí
   solo cambio sustantivo.
4. Los nombres de Wave 2 conservan la capitalización original (`CD1a`), pero la
   comparación entre olas usa una clave en mayúsculas (`CD1A`).
5. Antes de mapear con PaRIS deben revisarse concepto, pregunta, universo,
   periodo, representación y regla nacional aplicable.

## Próxima revisión manual

- Validar las 43 variables exclusivas de ola contra los manuales oficiales.
- Revisar primero variables candidatas a armonización con PaRIS: edad, sexo,
  salud autopercibida, cronicidad, funcionamiento, salud mental y utilización.
- Convertir reglas nacionales en una tabla normalizada país-variable-regla.
- Vincular cada variable con pregunta, medida, universo y dominio conceptual.
