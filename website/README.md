# Sitio público PaRIS–EHIS

Sitio híbrido para Workers Static Assets. El programa, los paquetes de trabajo,
el marco/DataSchema, las encuestas/métodos, el roadmap y el catálogo WP1A son
HTML/CSS/JavaScript propios; únicamente el protocolo se renderiza con Quarto
para conservar citas, resaltados y anotaciones. La parte pública no
contiene microdatos, abstracts licenciados, credenciales ni documentación
restringida.

La estructura mantenible de los paquetes reside en
`website/data/work-packages.json` y se representa mediante
`website/programme.js`. `referencias.html` conserva su URL por compatibilidad,
pero forma parte de WP1A y no constituye una sección principal independiente.

## Regeneración

Desde la raíz del repositorio:

```powershell
Rscript --vanilla scripts/13_build_public_website.R
Rscript --vanilla scripts/15_render_public_website.R
```

El script actualiza `website/data/project-status.json` a partir de las matrices
locales. También genera las estrategias exactas y una lista de referencias
PubMed regenerables desde NCBI. Los registros exclusivos de exportaciones
Scopus/Embase no se copian al directorio público. El segundo script renderiza
solo `protocolo.qmd` y copia las páginas estáticas en `website/_site/`.

## Cloudflare Workers

- Build command: `Rscript --vanilla scripts/13_build_public_website.R && quarto render website`.
- Build output directory: `website/_site`.
- Root directory: raíz del repositorio.

Para una vista temporal sin autenticación también se puede utilizar Workers
Static Assets mediante `wrangler.jsonc`:

```powershell
npx.cmd --yes wrangler@latest deploy
```

El despliegue publica únicamente `website/_site/` como activos estáticos y
mantiene las rutas `/api/*` en el Worker.

Antes de desplegar se debe revisar el diff de `website/data/project-status.json`
y ejecutar las pruebas del proyecto. La página de protocolo activa resaltados y
anotaciones mediante Hypothesis; las anotaciones privadas requieren un grupo
privado configurado en ese servicio.

La configuración editable de revisores reside únicamente en
`cloudflare/reviewers.local.csv`, ignorado por Git. La carga privada se prepara
y sincroniza con:

```powershell
Rscript --vanilla scripts/16_prepare_cloudflare_review_import.R
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/17_import_cloudflare_d1.ps1
```
