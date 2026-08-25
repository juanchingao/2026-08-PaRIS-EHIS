# Hoja de ruta de la web pública de armonización PaRIS

> **Estado desde 2026-08-24:** desarrollo funcional en pausa. Solo se mantiene
> la página del protocolo para documentar la reorientación científica.

## Propósito

Ofrecer una vista clara y verificable del avance sin publicar materiales
restringidos. La web es un producto de comunicación, no el registro científico
canónico: las decisiones siguen residiendo en las tablas y documentos del
repositorio.

## Alcance inicial

- estado agregado de búsqueda y cribado;
- landing breve con acceso a páginas especializadas;
- catálogo de referencias con filtros por base y decisión final y columnas
  independientes para IA, JALR e investigador 2;
- inventario agregado de metadatos;
- principios metodológicos y salvaguardas;
- hoja de ruta del piloto;
- fecha de última regeneración.
- protocolo Quarto con estructura Introducción, Métodos, Discusión y Ética,
  sin resultados, bibliografía, anexos y anotaciones Hypothesis;
- sección pública de estado metodológico y alineación Maelstrom.

Quedan fuera microdatos, abstracts licenciados, listados bibliográficos
completos, claves API, rutas locales y documentos de acceso restringido.

## Evolución propuesta

1. Mantener publicada la versión Quarto multipágina mediante Workers Static
   Assets.
2. Mantener el área privada ya creada con Cloudflare Access OTP, allowlist de
   correos, Worker y D1 para doble revisión cegada y adjudicación.
3. Añadir una página de evidencia con citas públicas una vez depurada la nueva
   extracción de las referencias incluidas.
4. Publicar fichas agregadas de los siete casos piloto cuando las variables
   objetivo y assessments estén revisados.
5. Incorporar historial de versiones y descargas únicamente para tablas
   aprobadas expresamente para difusión.
6. Automatizar el despliegue solo después de incorporar una validación que
   bloquee archivos sensibles y resultados con riesgo de disclosure.

## Criterios antes de cada despliegue

- regeneración local satisfactoria;
- pruebas completas sin fallos;
- revisión de secretos y archivos ignorados;
- contenido exclusivamente agregado o expresamente público;
- fecha, versión y limitaciones visibles.
