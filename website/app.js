const number = new Intl.NumberFormat('es-ES');

function setText(id, value) {
  const element = document.getElementById(id);
  if (element) element.textContent = value;
}

function setWidth(id, value, total) {
  const element = document.getElementById(id);
  if (element) element.style.width = `${(100 * value / total).toFixed(2)}%`;
}

fetch('data/project-status.json')
  .then((response) => {
    if (!response.ok) throw new Error('No se pudo cargar el estado público.');
    return response.json();
  })
  .then((data) => {
    const literature = data.literature;
    const totalMetadata = data.metadata.paris_variables + data.metadata.ehis_variables;
    setText('updated', new Date(`${data.updated}T00:00:00`).toLocaleDateString('es-ES'));
    setText('retrieved', number.format(literature.retrieved_unique));
    setText('screened', number.format(literature.screened_unique));
    setText('included', number.format(literature.include));
    setText('metadata-total', number.format(totalMetadata));
    setText('screening-total', `${number.format(literature.screened_unique)} decisiones únicas`);
    setText('include-count', number.format(literature.include));
    setText('background-count', number.format(literature.background));
    setText('exclude-count', number.format(literature.exclude));
    setText('duplicate-count', number.format(literature.duplicate_copies));
    setText('paris-vars', number.format(data.metadata.paris_variables));
    setText('ehis-vars', number.format(data.metadata.ehis_variables));
    setWidth('bar-include', literature.include, literature.screened_unique);
    setWidth('bar-background', literature.background, literature.screened_unique);
    setWidth('bar-exclude', literature.exclude, literature.screened_unique);
  })
  .catch(() => setText('updated', 'Estado temporalmente no disponible'));
