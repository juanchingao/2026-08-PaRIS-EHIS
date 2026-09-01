# Auditoría de fuentes y API bibliográficas

**Fecha de comprobación:** 2026-08-25  
**Alcance:** inspección no destructiva; ningún valor de autenticación se mostró
ni se escribió en el repositorio.

## PubMed/MEDLINE

- **Proveedor/plataforma:** National Center for Biotechnology Information,
  Entrez Programming Utilities.
- **Endpoints usados:** `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`
  y `efetch.fcgi`.
- **Autenticación:** no obligatoria; `NCBI_API_KEY` es opcional. `NCBI_EMAIL` y
  un nombre de herramienta deben acompañar las llamadas reproducibles.
- **Paginación:** `usehistory=y`, `WebEnv` y `query_key`; `retstart`/`retmax` en
  EFetch. El pipeline usa lotes de 200.
- **Límites:** hasta 3 solicitudes por segundo sin clave y 10 con clave; el
  pipeline aplica pausas conservadoras.
- **Formato:** XML de PubMed. Se recuperan PMID, DOI, título, resumen, autores,
  año, revista, tipos de publicación, idioma, palabras clave y MeSH.
- **Prueba mínima:** correcta; una búsqueda por DOI devolvió un registro y un
  historial válido.
- **Documentación:** <https://www.ncbi.nlm.nih.gov/books/NBK25499/>.

## Scopus

- **Proveedor/plataforma:** Elsevier, Scopus Search API.
- **Endpoint:** `https://api.elsevier.com/content/search/scopus`.
- **Integración reutilizada:** paquete R `scopusflow` 0.4.0.
- **Autenticación:** cabecera `X-ELS-APIKey`; token institucional opcional. Los
  valores se leen de entorno y nunca se registran.
- **Paginación:** la documentación admite hasta 200 registros STANDARD por
  página, pero la autorización actual rechazó `count=200` y aceptó `count=25`.
  El pipeline usa por ello 25. El paquete dispone de desplazamiento y cursor;
  Elsevier limita el desplazamiento a una ventana de 5.000.
- **Cuota:** cabeceras de cuota semanal y rate limit, conservadas solo como
  métricas no sensibles.
- **Campos de Search API usados:** Scopus ID/EID, DOI, título, autores, año,
  fecha, fuente y citas. La procedencia de consulta se añade localmente.
- **Prueba mínima:** conteo y recuperación por desplazamiento correctos. El
  cursor devolvió HTTP 403 con la autorización actual. Abstract Retrieval
  devolvió HTTP 401; por tanto, no se afirma acceso a abstracts, palabras clave
  ni términos controlados mediante esta clave.
- **Mitigación:** si una línea supera 5.000 resultados se particionará por año y
  se comprobarán recuentos y solapamientos; una ejecución no recuperada por
  completo quedará marcada `TRUNCATED`.
- **Documentación:** <https://dev.elsevier.com/api_key_settings.html>.

## Embase

- **Proveedor/plataforma comprobada:** Elsevier Embase API, no Ovid Embase.
- **Endpoint:** `https://api.elsevier.com/content/embase/article`.
- **Autenticación:** `X-ELS-APIKey`; el pipeline admite token institucional
  separado si Elsevier lo requiere.
- **Paginación documentada:** `start` y `count`; tamaño predeterminado 25;
  respuesta JSON o XML.
- **Campos esperados:** identificador Embase, metadatos bibliográficos, resumen,
  términos libres y Emtree según la licencia y la respuesta efectiva.
- **Prueba mínima:** HTTP 403, código sanitizado `AUTHENTICATION_ERROR`, por
  configuración insuficiente para acceder al recurso. La clave existe, pero no
  autoriza Embase API.
- **Consecuencia:** no se ejecutaron las líneas A/B/C ni se validaron términos
  Emtree. Las exportaciones históricas de Embase.com siguen siendo importaciones
  RIS manuales y una fuente separada de Scopus.
- **Decisión del investigador (2026-08-25):** no continuar intentando la API,
  porque requiere un token o derecho institucional que la biblioteca no
  proporcionará. Si existe acceso a Embase.com, la única vía pendiente será la
  ejecución y exportación manual por línea.
- **Documentación:** <https://dev.elsevier.com/documentation/EmbaseAPI.wadl>.

## APA PsycINFO

- **Plataforma institucional confirmada:** EBSCOhost.
- **API configurada:** no.
- **Antecedente conservado:** la traducción Ovid v0.2 queda como borrador
  histórico y no debe ejecutarse en EBSCOhost.
- **Pendiente:** localizar el acceso institucional, traducir A/B/C a los campos
  y operadores de EBSCOhost, comprobar el APA Thesaurus dentro de la plataforma
  y probar las referencias semilla antes de asignar `SYNTAX_CHECKED`.
- **Documentación de vocabulario:**
  <https://www.apa.org/pubs/databases/training/thesaurus>.

## Web of Science Core Collection

- **Proveedor:** Clarivate.
- **API configurada:** `WOS_API_KEY_STARTER_SERMAS` está disponible en el
  entorno local; la credencial no se almacena ni se imprime. El 2026-09-01 se
  verificó Web of Science Starter API (`/apis/wos-starter/v1/documents`) con el
  encabezado exacto `X-ApiKey`: una consulta por el DOI
  `10.1093/ije/dyw075` devolvió `HTTP 200`, `total=1` y un registro. La variante
  `X-Api-Key` devuelve `HTTP 401` y no debe utilizarse. La credencial Expanded
  permanece separada y esta comprobación no demuestra acceso a Expanded.
- **Integración activa:** `scripts/32_run_wos_wp1_searches.R` usa paginación,
  reintentos acotados, backoff, checkpoints, UT únicos y manifiestos con hashes.
- **Fidelidad de campos:** se conservan consultas `TI`/`AB` como traducción
  operativa de PubMed y pilotos `TS` separados. `TS` incluye título, resumen,
  author keywords y Keywords Plus, por lo que no se considera equivalente a
  `Title/Abstract` y nunca sustituye silenciosamente la traducción fiel. La
  documentación pública de Starter enumera `TI` y `TS`, pero no `AB`; el
  endpoint aceptó `AB` sin error. Hasta confirmación de Clarivate, la ejecución
  es completa y reproducible, pero la semántica de campo permanece pendiente
  de validación y no se declara equivalencia documental.
- **Limitación observada:** Starter devolvió UID, título, autores, fuente, año,
  identificadores, tipos, author keywords y citas cuando el plan las permite,
  pero no abstracts, afiliaciones, Keywords Plus ni financiación. Los campos
  permanecen explícitos como no disponibles.
- **Estrategia histórica preparada:** interfaz Web of Science con campo `TS=`. La
  colección y los índices concretos deberán registrarse durante la ejecución.
- **Decisión del investigador (2026-08-25):** no continuar buscando acceso a
  la API, porque el token institucional no estará disponible. La estrategia
  `TS=` se conserva para una posible ejecución manual; si tampoco hay acceso a
  la interfaz, la fuente se declarará no disponible.
- **Reapertura (2026-08-28; verificada 2026-09-01):** el acceso Starter de
  SERMAS está operativo. No se ejecutará la descarga A/B/C mientras la pregunta
  de investigación y las estrategias de WP1 sigan en redefinición. Antes de una
  ejecución definitiva se documentarán los límites del plan, los campos
  disponibles y la estrategia adaptada a la sintaxis Starter.
- **Documentación:** <https://developer.clarivate.com/apis/wos-starter>.

## Seguridad y errores

Los scripts sanitizan mensajes HTTP, omiten cabeceras y cuerpos que puedan
contener autenticación y solo registran proveedor, endpoint público, código de
estado, clase de error y mensaje resumido. `.Renviron`, respuestas brutas y
exportaciones licenciadas están excluidos de Git.
