# Tercer revisor automático

Esta carpeta versiona el contrato científico del tercer revisor LLM. Los
resultados del modelo no son decisiones humanas, no adjudican desacuerdos y no
autorizan exclusiones automáticas.

## Diseño

- Método: cribado `multiprompt` independiente, un juicio por criterio.
- Unidad: referencia deduplicada.
- Input permitido: identificador, base, etapa, título y abstract disponible.
- Input prohibido: decisiones JALR/R2, propuestas anteriores, iniciales,
  puntuaciones de prioridad y notas humanas.
- Output: `INCLUDE`, `BACKGROUND` o `EXCLUDE`, criterio principal, valoración de
  cada criterio, suficiencia de evidencia y justificación breve.
- Cegamiento: la salida se congela antes de revelar ambas revisiones humanas.
- Título solo: la ausencia de abstract no justifica exclusión.

El modelo configurado inicialmente es `gpt-5.6-terra`. Es una elección operativa
por equilibrio entre calidad y coste, no un modelo entrenado específicamente en
revisiones sistemáticas. La independencia procede del diseño zero-shot y de la
exclusión verificable de las etiquetas humanas. ASReview/ELAS-lang se reserva
para experimentos de priorización y actualizaciones posteriores.

## Flujo reproducible

1. Preparar localmente el lote y el manifiesto, sin conexión externa:

   ```powershell
   Rscript --vanilla scripts/19_prepare_ai_screening_batch.R
   ```

2. Confirmar licencias y gobernanza. Solo entonces configurar en `.Renviron`:

   ```text
   OPENAI_API_KEY=...
   AI_SCREENING_ALLOW_RESTRICTED_UPLOAD=YES
   ```

3. Enviar, consultar y descargar el Batch:

   ```powershell
   Rscript --vanilla scripts/20_openai_ai_screening_batch.R submit
   Rscript --vanilla scripts/20_openai_ai_screening_batch.R status
   Rscript --vanilla scripts/20_openai_ai_screening_batch.R download
   ```

4. Validar los 1.076 resultados y preparar SQL congelado:

   ```powershell
   Rscript --vanilla scripts/21_prepare_ai_screening_d1_import.R
   ```

5. Tras revisar el resumen de decisiones, importar el SQL con el cargador D1:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/17_import_cloudflare_d1.ps1 `
     -SqlPath data/interim/ai-screening/openai-systematic-screening-v1/model-assessments.sql
   ```

Los requests, manifests, estados, resultados y SQL se escriben bajo
`data/interim/ai-screening/`, excluido de Git. El repositorio solo conserva
criterios, prompt, esquema, código y documentación.

## Evaluación

La salida se comparará después con consenso/adjudicación humana. Se informarán
sensibilidad, especificidad, valor predictivo negativo, falsos negativos,
rendimiento por base y disponibilidad de abstract y carga ahorrada a distintas
sensibilidades. Ningún umbral se calibrará y evaluará sobre los mismos registros.
