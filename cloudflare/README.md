# Arquitectura privada de revisión en Cloudflare

> **Estado desde 2026-08-24:** infraestructura preservada, sin nuevas funciones
> de cribado ni cargas de IA hasta aprobar el protocolo v0.3 y el WP1.

La landing, el protocolo y los metadatos PubMed de `website/` son públicos. Las
decisiones y la doble revisión necesitan una capa separada y autenticada:

- Workers Static Assets para las páginas Quarto públicas;
- Cloudflare Access para autenticar investigadores;
- Worker para la API privada;
- D1 para referencias, decisiones, adjudicaciones y evaluaciones automáticas.

Estado remoto actual:

- cuenta: `paris-ehis`;
- Worker público: `paris-ehis-progress`;
- URL: `https://paris-ehis-progress.paris-ehis.workers.dev`;
- D1: `paris-ehis-review` (región `WEUR`), con esquema aplicado;
- API privada implementada en el Worker y protegida por Access;
- D1 contiene 1.091 filas bibliográficas, 1.076 registros efectivos, 1.091
  decisiones JALR y 891 evaluaciones automáticas;
- revisores configurados: `JALR` y `R2`; desde 2026-09-01, la configuración
  local, D1 y la allowlist de Access asignan `R2` a Alicia Serrano Vedruna. La
  actualización remota se verificó con `R2` activo y rol `REVIEWER`. Los correos
  se mantienen en una configuración local editable y excluida de Git;
- Access OTP activo para `/api/*`, con allowlist exacta de los dos revisores;
  landing, referencias públicas y protocolo permanecen accesibles sin sesión.

La autenticación prevista es Cloudflare Access con One-Time PIN. La política
`Allow` debe enumerar direcciones de correo concretas; no debe utilizar
`Include everyone` ni aceptar cualquier usuario que disponga de OTP. El PIN es
de un solo uso y expira a los diez minutos. El Worker verificará el JWT de
Access y asociará su identidad con `reviewers.email`/`access_subject`; no
confiará en un correo enviado por el cliente.

`schema.sql` define el modelo inicial. La base remota se denomina
`paris-ehis-review` y está vinculada como `DB` en `wrangler.jsonc`. El Worker
rechaza `/api/*` con `503` mientras falten `ACCESS_AUD` y
`ACCESS_TEAM_DOMAIN`; después valida el JWT de Access y comprueba que el correo
pertenece a un revisor activo en D1.

Para cambiar el correo de un revisor se edita
`cloudflare/reviewers.local.csv` y se vuelven a ejecutar
`scripts/16_prepare_cloudflare_review_import.R` y
`scripts/17_import_cloudflare_d1.ps1`.
El archivo local no debe añadirse a Git. El cambio debe reflejarse también en la
política allowlist de Cloudflare Access mediante
`scripts/18_configure_cloudflare_access.ps1` cuando esta esté activa.

Para este proyecto se ha autorizado el almacenamiento privado de abstracts de
Embase en D1. Deben marcarse como `RESTRICTED`, servirse solo desde rutas
protegidas por Access y quedar excluidos de logs, respuestas públicas y exports
destinados a Pages.

La página `referencias.html` actúa también como puesto de cribado cuando existe
una sesión autorizada. La lista no transporta abstracts: cada resumen se obtiene
bajo demanda desde `/api/references/:record_id`. El formulario permite registrar
`INCLUDE`, `BACKGROUND` o `EXCLUDE`, un motivo controlado y notas opcionales.
Cada guardado crea una revisión nueva; la decisión anterior no se actualiza ni
se elimina. Las escrituras JSON requieren además un `Origin` del propio sitio.

La columna `IA sistemática` está fijada por `AI_MODEL_RUN_ID` a
`openai-systematic-screening-v1`. Mientras esa corrida no se haya importado,
aparece pendiente. Las 891 propuestas históricas permanecen en D1 para
auditoría, pero no se mezclan con la nueva tercera revisión.

## Reglas funcionales

1. Cada investigador solo ve su propia decisión mientras el otro no haya
   terminado el registro.
2. El consenso se calcula después de congelar ambas decisiones.
3. Los desacuerdos pasan a adjudicación; nunca se resuelven automáticamente.
4. La propuesta automática permanece oculta hasta congelar las dos revisiones
   humanas, para evitar sesgo de anclaje.
5. Cada modificación conserva revisor, instante y número de revisión.
6. Las rutas públicas nunca consultan tablas con abstracts restringidos.
