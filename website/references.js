const refNumber = new Intl.NumberFormat('es-ES');
const refDate = new Intl.DateTimeFormat('es-ES', {
  dateStyle: 'medium',
  timeStyle: 'short'
});
const decisionLabels = {
  INCLUDE: 'Incluir',
  BACKGROUND: 'Contexto',
  EXCLUDE: 'Excluir'
};
const reasonLabels = {
  MEETS_INCLUSION_CRITERIA: 'Cumple los criterios de inclusión',
  METHODOLOGICAL_BACKGROUND: 'Aporta contexto metodológico',
  OUT_OF_SCOPE: 'Fuera del alcance',
  WRONG_POPULATION: 'Población no pertinente',
  WRONG_CONSTRUCT: 'Constructo o medida no pertinente',
  WRONG_DESIGN: 'Diseño no pertinente',
  DUPLICATE: 'Duplicado',
  INSUFFICIENT_INFORMATION: 'Información insuficiente',
  OTHER: 'Otro motivo'
};

let allReferences = [];
let currentReviewer = null;
let currentPage = 1;
const pageSize = 50;

function refEscape(value) {
  return String(value ?? '').replace(/[&<>'"]/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;'
  })[character]);
}

function decisionBadge(value) {
  const shown = value || 'PENDING';
  const label = decisionLabels[shown] || 'Pendiente';
  return `<span class="decision ${shown.toLowerCase()}">${refEscape(label)}</span>`;
}

function safeHttpUrl(value) {
  try {
    const url = new URL(value);
    return ['http:', 'https:'].includes(url.protocol) ? url.href : null;
  } catch {
    return null;
  }
}

function identifierHtml(reference) {
  if (reference.doi) {
    return `<a href="https://doi.org/${encodeURIComponent(reference.doi)}" rel="noopener">${refEscape(reference.doi)}</a>`;
  }
  if (reference.pmid) {
    return `<a href="https://pubmed.ncbi.nlm.nih.gov/${encodeURIComponent(reference.pmid)}/" rel="noopener">PMID ${refEscape(reference.pmid)}</a>`;
  }
  const sourceUrl = safeHttpUrl(reference.source_url);
  if (sourceUrl) {
    return `<a href="${refEscape(sourceUrl)}" rel="noopener">Registro original</a>`;
  }
  return refEscape(reference.source_id || 'Sin identificador externo');
}

function reasonOptions(selectedReason) {
  const emptySelected = selectedReason ? '' : ' selected';
  return `<option value=""${emptySelected}>Sin motivo codificado</option>${Object.entries(reasonLabels).map(([value, label]) => (
    `<option value="${value}"${selectedReason === value ? ' selected' : ''}>${refEscape(label)}</option>`
  )).join('')}`;
}

function decisionOptions(selectedDecision) {
  return Object.entries(decisionLabels).map(([value, label]) => `
    <label class="decision-option ${value.toLowerCase()}">
      <input type="radio" name="decision" value="${value}"${selectedDecision === value ? ' checked' : ''} required>
      <span>${refEscape(label)}</span>
    </label>`).join('');
}

function reviewRow(reference) {
  if (!currentReviewer) return '';
  const review = reference.current_review;
  const revisionText = review
    ? `Revisión ${review.revision} · ${refEscape(refDate.format(new Date(review.decided_at)))}`
    : 'Aún no has guardado una decisión';
  return `
    <tr class="review-row">
      <td colspan="6">
        <details class="review-details" data-record-id="${refEscape(reference.record_id)}" data-abstract-state="idle">
          <summary>
            <span>Resumen y revisión</span>
            ${decisionBadge(review?.decision)}
          </summary>
          <div class="review-panel">
            <section class="abstract-block" aria-labelledby="abstract-${refEscape(reference.record_id)}">
              <p class="review-kicker">Resumen</p>
              <h3 id="abstract-${refEscape(reference.record_id)}">${refEscape(reference.title)}</h3>
              <p class="abstract-text">Abre este panel para cargar el resumen privado.</p>
            </section>
            <form class="review-form" data-record-id="${refEscape(reference.record_id)}">
              <div class="review-form-heading">
                <div>
                  <p class="review-kicker">Tu revisión · ${refEscape(currentReviewer.reviewer_id)}</p>
                  <h3>Decisión de título y resumen</h3>
                </div>
                <span class="revision-note">${revisionText}</span>
              </div>
              <fieldset>
                <legend>Decisión</legend>
                <div class="decision-options">${decisionOptions(review?.decision)}</div>
              </fieldset>
              <label>Motivo
                <select name="reason_code">${reasonOptions(review?.reason_code)}</select>
              </label>
              <label>Notas para la trazabilidad
                <textarea name="notes" maxlength="5000" rows="3" placeholder="Opcional">${refEscape(review?.notes || '')}</textarea>
              </label>
              <div class="review-actions">
                <span class="form-status" role="status"></span>
                <button type="submit">${review ? 'Guardar nueva revisión' : 'Guardar decisión'}</button>
              </div>
            </form>
          </div>
        </details>
      </td>
    </tr>`;
}

function renderReferenceFilters() {
  const sources = [...new Set(allReferences.map((reference) => reference.source_database || reference.source))].sort();
  const select = document.getElementById('source-filter');
  select.replaceChildren(select.options[0]);
  sources.forEach((source) => {
    const option = document.createElement('option');
    option.value = source;
    option.textContent = source;
    select.appendChild(option);
  });
}

function filteredReferences() {
  const query = document.getElementById('reference-search').value.trim().toLocaleLowerCase('es');
  const source = document.getElementById('source-filter').value;
  const finalDecision = document.getElementById('decision-filter').value;
  const reviewStatus = document.getElementById('review-filter').value;
  return allReferences.filter((reference) => {
    const haystack = [reference.title, reference.doi, reference.pmid, reference.journal]
      .join(' ').toLocaleLowerCase('es');
    const referenceSource = reference.source_database || reference.source;
    const resolved = reference.final_decision || 'PENDING';
    const ownStatus = reference.current_review ? 'REVIEWED' : 'PENDING';
    return haystack.includes(query) &&
      (!source || referenceSource === source) &&
      (!finalDecision || resolved === finalDecision) &&
      (!reviewStatus || ownStatus === reviewStatus);
  });
}

function renderReferenceTable() {
  const visible = filteredReferences();
  const pageCount = Math.max(1, Math.ceil(visible.length / pageSize));
  currentPage = Math.min(Math.max(currentPage, 1), pageCount);
  const pageStart = (currentPage - 1) * pageSize;
  const pageReferences = visible.slice(pageStart, pageStart + pageSize);
  document.getElementById('reference-summary').textContent = `${refNumber.format(visible.length)} de ${refNumber.format(allReferences.length)} referencias`;
  document.getElementById('reference-rows').innerHTML = pageReferences.map((reference) => {
    const sourceName = reference.source_database || reference.source;
    const primaryRow = `<tr class="reference-row">
      <td><strong>${refEscape(reference.title)}</strong><br><span class="reference-meta">${refEscape(reference.journal || '')} · ${identifierHtml(reference)}</span></td>
      <td>${refEscape(sourceName)}</td>
      <td>${decisionBadge(reference.ai_decision)}</td>
      <td>${decisionBadge(reference.jalr_decision)}</td>
      <td>${decisionBadge(reference.reviewer2_decision)}</td>
      <td>${decisionBadge(reference.final_decision)}</td>
    </tr>`;
    return primaryRow + reviewRow(reference);
  }).join('');
  document.getElementById('page-status').textContent = `Página ${currentPage} de ${pageCount}`;
  document.getElementById('previous-page').disabled = currentPage <= 1;
  document.getElementById('next-page').disabled = currentPage >= pageCount;
}

function setFeedback(message, tone = '') {
  const feedback = document.getElementById('review-feedback');
  feedback.textContent = message;
  feedback.className = `review-feedback ${tone}`.trim();
}

async function privateJson(path, options = {}) {
  try {
    const response = await fetch(path, {
      credentials: 'same-origin',
      ...options
    });
    const contentType = response.headers.get('content-type') || '';
    if (!response.ok || !contentType.includes('application/json')) return null;
    return response;
  } catch {
    return null;
  }
}

async function loadAbstract(details) {
  if (!details.open || details.dataset.abstractState !== 'idle') return;
  details.dataset.abstractState = 'loading';
  const abstract = details.querySelector('.abstract-text');
  abstract.textContent = 'Cargando resumen…';
  try {
    const response = await privateJson(`/api/references/${encodeURIComponent(details.dataset.recordId)}`);
    if (!response) throw new Error('abstract unavailable');
    const record = await response.json();
    abstract.textContent = record.abstract_text || 'No hay resumen disponible para este registro.';
    details.dataset.abstractState = 'loaded';
  } catch {
    abstract.textContent = 'No se pudo cargar el resumen. Vuelve a intentarlo.';
    details.dataset.abstractState = 'idle';
  }
}

async function refreshPrivateReferences() {
  const response = await privateJson('/api/references');
  if (!response) throw new Error('private references unavailable');
  allReferences = await response.json();
}

async function saveReview(form) {
  const button = form.querySelector('button[type="submit"]');
  const formStatus = form.querySelector('.form-status');
  const formData = new FormData(form);
  const payload = {
    record_id: form.dataset.recordId,
    decision: formData.get('decision'),
    reason_code: formData.get('reason_code') || null,
    notes: formData.get('notes') || null
  };
  button.disabled = true;
  formStatus.textContent = 'Guardando…';
  try {
    const response = await privateJson('/api/decisions', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!response) throw new Error('save unavailable');
    const saved = await response.json();
    await refreshPrivateReferences();
    renderReferenceTable();
    setFeedback(`Decisión guardada como revisión ${saved.review.revision}. El historial anterior se conserva.`, 'success');
  } catch {
    button.disabled = false;
    formStatus.textContent = 'No se pudo guardar.';
    setFeedback('No se ha modificado la decisión. Revisa la conexión e inténtalo de nuevo.', 'error');
  }
}

function bindControls() {
  ['reference-search', 'source-filter', 'decision-filter', 'review-filter'].forEach((id) => {
    document.getElementById(id).addEventListener(id === 'reference-search' ? 'input' : 'change', () => {
      currentPage = 1;
      renderReferenceTable();
    });
  });
  document.getElementById('previous-page').addEventListener('click', () => {
    currentPage -= 1;
    renderReferenceTable();
  });
  document.getElementById('next-page').addEventListener('click', () => {
    currentPage += 1;
    renderReferenceTable();
  });
  document.getElementById('reference-rows').addEventListener('toggle', (event) => {
    if (event.target.matches('.review-details')) loadAbstract(event.target);
  }, true);
  document.getElementById('reference-rows').addEventListener('submit', (event) => {
    if (!event.target.matches('.review-form')) return;
    event.preventDefault();
    saveReview(event.target);
  });
}

async function loadReferences() {
  const privateResponse = await privateJson('/api/references');
  if (privateResponse) {
    const reviewerResponse = await privateJson('/api/me');
    if (!reviewerResponse) throw new Error('reviewer unavailable');
    currentReviewer = await reviewerResponse.json();
    allReferences = await privateResponse.json();
    document.getElementById('access-state').textContent = `Área privada · ${currentReviewer.reviewer_id}`;
    document.getElementById('access-description').textContent = `${currentReviewer.display_name}: tus decisiones están editables; las demás capas respetan el cegamiento.`;
    document.getElementById('review-filter-control').hidden = false;
    const accessLink = document.getElementById('access-link');
    accessLink.textContent = 'Cerrar sesión';
    accessLink.href = '/cdn-cgi/access/logout';
  } else {
    const response = await fetch('data/references.json');
    if (!response.ok) throw new Error('public references unavailable');
    allReferences = await response.json();
  }
  renderReferenceFilters();
  renderReferenceTable();
  bindControls();
}

loadReferences().catch(() => {
  document.getElementById('reference-summary').textContent = 'No se pudieron cargar las referencias.';
});
