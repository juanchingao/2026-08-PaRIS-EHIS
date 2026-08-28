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
- **API configurada:** `WOS_API_KEY` está disponible en el entorno local desde
  2026-08-28; la credencial no se almacena ni se imprime. Las consultas mínimas
  a Web of Science Starter API (`/apis/wos-starter/v1/documents`) y Web of
  Science API Expanded (`/api/wos`) alcanzaron el proveedor, pero ambas
  devolvieron `HTTP 401 Unauthorized`. La clave está presente una sola vez,
  sin espacios, por lo que la incidencia se clasifica provisionalmente como
  autenticación o suscripción de la aplicación, no como fallo de red o de
  sintaxis de consulta.
- **Estrategia preparada:** interfaz Web of Science con campo `TS=`. La
  colección y los índices concretos deberán registrarse durante la ejecución.
- **Decisión del investigador (2026-08-25):** no continuar buscando acceso a
  la API, porque el token institucional no estará disponible. La estrategia
  `TS=` se conserva para una posible ejecución manual; si tampoco hay acceso a
  la interfaz, la fuente se declarará no disponible.
- **Reapertura (2026-08-28):** el investigador facilitó una nueva clave y
  autorizó su uso. No se desarrollará ni ejecutará la descarga A/B/C hasta que
  Clarivate active al menos uno de los productos para la aplicación y una
  consulta mínima devuelva `HTTP 200`.
- **Documentación:** <https://developer.clarivate.com/apis/wos>.

## Seguridad y errores

Los scripts sanitizan mensajes HTTP, omiten cabeceras y cuerpos que puedan
contener autenticación y solo registran proveedor, endpoint público, código de
estado, clase de error y mensaje resumido. `.Renviron`, respuestas brutas y
exportaciones licenciadas están excluidos de Git.
