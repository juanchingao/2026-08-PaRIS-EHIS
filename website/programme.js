const statusLabels = {
  PROPOSED: 'Propuesto',
  INITIAL_PILOT: 'Piloto inicial',
  FUTURE_EXPANSION: 'Expansión futura'
};

const escapeHtml = (value) => String(value ?? '')
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;').replaceAll("'", '&#039;');

function list(items) {
  return `<ul>${items.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul>`;
}

function renderWp(wp) {
  const subpackages = wp.subpackages ? `<div class="wp-subpackages">${wp.subpackages.map((sub) => `
    <section class="wp-subpackage" aria-labelledby="${sub.id}-title">
      <p class="wp-code">${sub.id}</p><h4 id="${sub.id}-title">${escapeHtml(sub.title)}</h4>
      <p class="wp-question">${escapeHtml(sub.question)}</p>${list(sub.topics)}
      <p class="deliverable"><strong>Entregable:</strong> ${escapeHtml(sub.deliverable)}</p>
      ${sub.id === 'WP1A' ? '<a class="text-link" href="referencias.html">Abrir referencias y cribado de WP1A →</a>' : ''}
    </section>`).join('')}</div>` : '';
    return `<article class="wp-detail" id="${wp.id.toLowerCase()}">
    <header class="wp-header"><div><p class="wp-code">${wp.id} · ${escapeHtml(wp.phase)}</p><h3>${escapeHtml(wp.title)}</h3></div><span class="state state-${wp.status.toLowerCase()}">${statusLabels[wp.status]}</span></header>
    <p class="wp-purpose">${escapeHtml(wp.purpose)}</p>
    ${subpackages}
    <div class="wp-detail-grid">
      <section><h4>Preguntas</h4>${list(wp.researchQuestions)}</section>
      <section><h4>Actividades</h4>${list(wp.activities)}</section>
      <section><h4>Entregables</h4>${list(wp.deliverables)}</section>
      <section><h4>Perfiles necesarios</h4>${list(wp.requiredExpertise)}</section>
    </div>
    <footer class="wp-gate"><strong>Dependencias:</strong> ${wp.dependencies.length ? wp.dependencies.join(', ') : 'Ninguna'}<br><strong>Gate:</strong> ${escapeHtml(wp.decisionGate)}</footer>
  </article>`;
}

function requestedPackageIndex(packages) {
  const requestedId = window.location.hash.slice(1).toUpperCase();
  const index = packages.findIndex((wp) => wp.id === requestedId);
  return index >= 0 ? index : 0;
}

function renderExplorer(target, packages) {
  let activeIndex = requestedPackageIndex(packages);
  target.innerHTML = `<div class="wp-explorer">
    <div class="wp-selector" role="tablist" aria-label="Seleccionar paquete de trabajo">
      ${packages.map((wp, index) => `<button type="button" role="tab" id="tab-${wp.id.toLowerCase()}" aria-controls="wp-panel" aria-selected="${index === activeIndex}" tabindex="${index === activeIndex ? '0' : '-1'}" data-wp-index="${index}"><span>${wp.id}</span><strong>${escapeHtml(wp.shortTitle)}</strong></button>`).join('')}
    </div>
        <div id="wp-panel" class="wp-panel" role="tabpanel" tabindex="0"></div>
  </div>`;

  const selector = target.querySelector('.wp-selector');
  const panel = target.querySelector('#wp-panel');

  function selectPackage(index, { focusTab = false, updateHash = true } = {}) {
    activeIndex = (index + packages.length) % packages.length;
    const tabs = [...selector.querySelectorAll('[role="tab"]')];
    tabs.forEach((tab, tabIndex) => {
      const selected = tabIndex === activeIndex;
      tab.setAttribute('aria-selected', String(selected));
      tab.tabIndex = selected ? 0 : -1;
    });
      panel.innerHTML = renderWp(packages[activeIndex]);
      panel.setAttribute('aria-labelledby', tabs[activeIndex].id);
    if (focusTab) tabs[activeIndex].focus();
    if (updateHash) history.replaceState(null, '', `#${packages[activeIndex].id.toLowerCase()}`);
  }

  selector.addEventListener('click', (event) => {
    const tab = event.target.closest('[role="tab"]');
    if (tab) selectPackage(Number(tab.dataset.wpIndex), { focusTab: true });
  });
  selector.addEventListener('keydown', (event) => {
    const keys = ['ArrowLeft', 'ArrowRight', 'Home', 'End'];
    if (!keys.includes(event.key)) return;
    event.preventDefault();
    const nextIndex = event.key === 'Home' ? 0 : event.key === 'End' ? packages.length - 1 : activeIndex + (event.key === 'ArrowRight' ? 1 : -1);
    selectPackage(nextIndex, { focusTab: true });
  });
  window.addEventListener('hashchange', () => {
    selectPackage(requestedPackageIndex(packages), { updateHash: false });
  });
  selectPackage(activeIndex, { updateHash: false });
}

fetch('data/work-packages.json')
  .then((response) => { if (!response.ok) throw new Error('work packages unavailable'); return response.json(); })
  .then((packages) => {
    document.querySelectorAll('[data-wp-list]').forEach((target) => {
      renderExplorer(target, packages);
    });
  })
  .catch(() => {
    document.querySelectorAll('[data-wp-list]').forEach((target) => {
      target.innerHTML = '<p class="error-note">No se pudo cargar la estructura de paquetes de trabajo.</p>';
    });
  });
