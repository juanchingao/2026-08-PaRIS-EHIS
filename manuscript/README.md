# Manuscript

El borrador inicial de la introducción está disponible en
`introduction.qmd`. Es un documento Quarto autónomo, compilable en HTML, DOCX o
PDF, con referencias en `references.bib` y el formato bibliográfico de BioMed
Central definido en `biomed-central.csl`.

La introducción deberá revisarse cuando se estabilicen el modelo, el piloto de
armonización y el plan estadístico. Todavía no contiene resultados del estudio.

Para generar la versión HTML desde la raíz del proyecto:

```powershell
quarto render manuscript/introduction.qmd --to html
```
