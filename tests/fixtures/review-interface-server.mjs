import { createReadStream } from 'node:fs';
import { readFile, stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { dirname, extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const fixtureDir = dirname(fileURLToPath(import.meta.url));
const siteRoot = normalize(join(fixtureDir, '..', '..', 'website', '_site'));
const port = Number(process.env.REVIEW_PREVIEW_PORT || 8811);
const records = [
  {
    record_id: 'SYNTHETIC-001', source_database: 'Embase', source_id: 'SYNTHETIC-001',
    pmid: null, title: 'Retrospective harmonisation of patient-reported outcomes across European health surveys',
    doi: '10.0000/synthetic.001', journal: 'Journal of Synthetic Evidence', year: 2025,
    stage: 'TITLE_ABSTRACT', ai_decision: null, jalr_decision: 'INCLUDE',
    reviewer2_decision: null, final_decision: null,
    current_review: {
      record_id: 'SYNTHETIC-001', decision: 'INCLUDE', reason_code: 'MEETS_INCLUSION_CRITERIA',
      notes: 'Marco pertinente para el piloto de armonización.', decided_at: '2026-08-24T08:30:00.000Z', revision: 1
    }
  },
  {
    record_id: 'SYNTHETIC-002', source_database: 'Scopus', source_id: 'SYNTHETIC-002',
    pmid: null, title: 'A synthetic example awaiting independent title and abstract screening',
    doi: null, journal: 'Methods Preview', year: 2024, stage: 'TITLE_ABSTRACT',
    ai_decision: null, jalr_decision: null, reviewer2_decision: null,
    final_decision: null, current_review: null
  }
];
const abstracts = {
  'SYNTHETIC-001': 'This synthetic abstract describes a transparent, concept-first approach to retrospective harmonisation. It is used only to verify the private screening interface.',
  'SYNTHETIC-002': 'Synthetic content for visual testing. No licensed or individual-level data are included.'
};
const mimeTypes = {
  '.css': 'text/css; charset=utf-8', '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8', '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml'
};

function sendJson(response, value, status = 200) {
  response.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(value));
}

createServer(async (request, response) => {
  const url = new URL(request.url, `http://${request.headers.host}`);
  if (url.pathname === '/api/me') {
    return sendJson(response, { reviewer_id: 'JALR', display_name: 'Investigador JALR', role: 'REVIEWER' });
  }
  if (url.pathname === '/api/references') return sendJson(response, records);
  if (url.pathname.startsWith('/api/references/')) {
    const recordId = decodeURIComponent(url.pathname.slice('/api/references/'.length));
    const record = records.find((candidate) => candidate.record_id === recordId);
    return record
      ? sendJson(response, { record_id: recordId, title: record.title, abstract_text: abstracts[recordId], stage: record.stage, access_class: 'RESTRICTED' })
      : sendJson(response, { error: 'record_not_found' }, 404);
  }
  if (url.pathname === '/api/decisions' && request.method === 'POST') {
    return sendJson(response, { ok: true, review: { revision: 2 } });
  }

  const relativePath = url.pathname === '/' ? 'referencias.html' : decodeURIComponent(url.pathname.slice(1));
  const filePath = normalize(join(siteRoot, relativePath));
  if (!filePath.startsWith(siteRoot)) return sendJson(response, { error: 'not_found' }, 404);
  try {
    const fileInfo = await stat(filePath);
    if (!fileInfo.isFile()) throw new Error('not a file');
    response.writeHead(200, { 'content-type': mimeTypes[extname(filePath)] || 'application/octet-stream' });
    if (relativePath === 'references.js') {
      const script = await readFile(filePath, 'utf8');
      response.end(`${script}\nnew MutationObserver((_, observer) => { const first = document.querySelector('.review-details'); if (first) { first.open = true; observer.disconnect(); } }).observe(document.getElementById('reference-rows'), { childList: true });`);
      return;
    }
    createReadStream(filePath).pipe(response);
  } catch {
    sendJson(response, { error: 'not_found' }, 404);
  }
}).listen(port, '127.0.0.1', () => {
  process.stdout.write(`Synthetic review preview: http://127.0.0.1:${port}/referencias.html\n`);
});
