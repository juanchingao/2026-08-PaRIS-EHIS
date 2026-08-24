const DECISIONS = ["INCLUDE", "BACKGROUND", "EXCLUDE"];
const REASON_CODES = [
  "MEETS_INCLUSION_CRITERIA",
  "METHODOLOGICAL_BACKGROUND",
  "OUT_OF_SCOPE",
  "WRONG_POPULATION",
  "WRONG_CONSTRUCT",
  "WRONG_DESIGN",
  "DUPLICATE",
  "INSUFFICIENT_INFORMATION",
  "OTHER"
];

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
      "x-content-type-options": "nosniff"
    }
  });
}

function sameOrigin(request) {
  const origin = request.headers.get("Origin");
  return Boolean(origin && origin === new URL(request.url).origin);
}

function decodeBase64Url(value) {
  const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
  const binary = atob(normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "="));
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

async function verifyAccessIdentity(request, env) {
  if (!env.ACCESS_AUD || !env.ACCESS_TEAM_DOMAIN) return null;
  const token = request.headers.get("Cf-Access-Jwt-Assertion");
  if (!token) return null;
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  const header = JSON.parse(new TextDecoder().decode(decodeBase64Url(parts[0])));
  const payload = JSON.parse(new TextDecoder().decode(decodeBase64Url(parts[1])));
  const audience = Array.isArray(payload.aud) ? payload.aud : [payload.aud];
  const now = Math.floor(Date.now() / 1000);
  const expectedIssuer = `https://${env.ACCESS_TEAM_DOMAIN}`;
  if (!audience.includes(env.ACCESS_AUD) || payload.iss !== expectedIssuer ||
      !Number.isFinite(payload.exp) || payload.exp <= now ||
      (Number.isFinite(payload.nbf) && payload.nbf > now)) return null;

  const certs = await fetch(`https://${env.ACCESS_TEAM_DOMAIN}/cdn-cgi/access/certs`).then((response) => response.json());
  const jwk = certs.keys.find((key) => key.kid === header.kid);
  if (!jwk) return null;
  const key = await crypto.subtle.importKey(
    "jwk", jwk, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["verify"]
  );
  const valid = await crypto.subtle.verify(
    "RSASSA-PKCS1-v1_5", key, decodeBase64Url(parts[2]),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`)
  );
  return valid ? payload : null;
}

async function authorizedReviewer(request, env) {
  const identity = await verifyAccessIdentity(request, env);
  if (!identity?.email) return null;
  return env.DB.prepare(
    "SELECT reviewer_id, email, display_name, role FROM reviewers WHERE lower(email) = lower(?) AND active = 1"
  ).bind(identity.email).first();
}

async function listReferences(env, reviewer) {
  const query = `
    SELECT r.record_id, r.source_database, r.source_id, r.pmid, r.title,
      r.doi, r.journal, r.publication_year AS year, r.source_url, r.stage,
      (SELECT proposed_decision FROM model_assessments ma
       JOIN model_runs mr ON mr.model_run_id = ma.model_run_id
       WHERE ma.record_id = r.record_id AND mr.model_run_id = ?
       LIMIT 1) AS ai_decision,
      (SELECT decision FROM reviewer_decisions d WHERE d.record_id = r.record_id
       AND d.reviewer_id = 'JALR' ORDER BY revision DESC LIMIT 1) AS jalr_decision,
      (SELECT decision FROM reviewer_decisions d WHERE d.record_id = r.record_id
       AND d.reviewer_id = 'R2' ORDER BY revision DESC LIMIT 1) AS reviewer2_decision,
      (SELECT final_decision FROM adjudications a WHERE a.record_id = r.record_id) AS adjudicated_decision
    FROM review_records r
    WHERE r.duplicate_of IS NULL
    ORDER BY r.title`;
  const [result, ownReviews] = await Promise.all([
    env.DB.prepare(query).bind(env.AI_MODEL_RUN_ID || "").all(),
    env.DB.prepare(`
      SELECT d.record_id, d.decision, d.reason_code, d.notes,
        d.decided_at, d.revision
      FROM reviewer_decisions d
      JOIN (
        SELECT record_id, MAX(revision) AS revision
        FROM reviewer_decisions
        WHERE reviewer_id = ?
        GROUP BY record_id
      ) latest
        ON latest.record_id = d.record_id AND latest.revision = d.revision
      WHERE d.reviewer_id = ?`
    ).bind(reviewer.reviewer_id, reviewer.reviewer_id).all()
  ]);
  const ownReviewByRecord = new Map(
    ownReviews.results.map((review) => [review.record_id, review])
  );
  return result.results.map((record) => {
    const {
      ai_decision, jalr_decision, reviewer2_decision,
      adjudicated_decision, ...bibliographicRecord
    } = record;
    const privileged = ["ADJUDICATOR", "ADMIN"].includes(reviewer.role);
    const bothReviewed = Boolean(jalr_decision && reviewer2_decision);
    const revealCompletedReview = privileged || bothReviewed;
    const ownsJalrDecision = reviewer.reviewer_id === "JALR";
    const ownsReviewer2Decision = reviewer.reviewer_id === "R2";

    return {
      ...bibliographicRecord,
      ai_decision: revealCompletedReview ? ai_decision : null,
      jalr_decision: privileged || ownsJalrDecision || bothReviewed
        ? jalr_decision : null,
      reviewer2_decision: privileged || ownsReviewer2Decision || bothReviewed
        ? reviewer2_decision : null,
      final_decision: revealCompletedReview
        ? adjudicated_decision ||
          (jalr_decision === reviewer2_decision ? jalr_decision : null)
        : null,
      current_review: ownReviewByRecord.get(record.record_id) || null
    };
  });
}

async function getReference(env, recordId) {
  return env.DB.prepare(`
    SELECT record_id, title, abstract_text, stage, access_class
    FROM review_records
    WHERE record_id = ? AND duplicate_of IS NULL`
  ).bind(recordId).first();
}

async function saveDecision(request, env, reviewer) {
  if (!sameOrigin(request)) return json({ error: "invalid_origin" }, 403);
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }
  const reasonCode = body.reason_code || null;
  const notes = typeof body.notes === "string" ? body.notes.trim() : "";
  if (!body.record_id || !DECISIONS.includes(body.decision)) {
    return json({ error: "invalid_decision" }, 400);
  }
  if (reasonCode && !REASON_CODES.includes(reasonCode)) {
    return json({ error: "invalid_reason_code" }, 400);
  }
  if (notes.length > 5000) return json({ error: "notes_too_long" }, 400);
  const existing = await env.DB.prepare(
    "SELECT 1 FROM review_records WHERE record_id = ? AND duplicate_of IS NULL"
  ).bind(body.record_id).first();
  if (!existing) return json({ error: "record_not_found" }, 404);
  const latest = await env.DB.prepare(
    "SELECT COALESCE(MAX(revision), 0) AS revision FROM reviewer_decisions WHERE record_id = ? AND reviewer_id = ?"
  ).bind(body.record_id, reviewer.reviewer_id).first();
  const revision = Number(latest?.revision || 0) + 1;
  const decidedAt = new Date().toISOString();
  await env.DB.prepare(`
    INSERT INTO reviewer_decisions
      (record_id, reviewer_id, decision, reason_code, notes, decided_at, revision)
    VALUES (?, ?, ?, ?, ?, ?, ?)`
  ).bind(
    body.record_id, reviewer.reviewer_id, body.decision,
    reasonCode, notes || null, decidedAt, revision
  ).run();
  return json({
    ok: true,
    review: {
      record_id: body.record_id,
      reviewer_id: reviewer.reviewer_id,
      decision: body.decision,
      reason_code: reasonCode,
      notes: notes || null,
      decided_at: decidedAt,
      revision
    }
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (!url.pathname.startsWith("/api/")) return env.ASSETS.fetch(request);
    if (!env.ACCESS_AUD || !env.ACCESS_TEAM_DOMAIN) {
      return json({ error: "private_review_not_configured" }, 503);
    }
    const reviewer = await authorizedReviewer(request, env);
    if (!reviewer) return json({ error: "unauthorized" }, 401);
    if (url.pathname === "/api/login" && request.method === "GET") {
      return Response.redirect(new URL("/referencias.html", url), 302);
    }
    if (url.pathname === "/api/me") return json(reviewer);
    if (url.pathname === "/api/references" && request.method === "GET") {
      return json(await listReferences(env, reviewer));
    }
    const referenceMatch = url.pathname.match(/^\/api\/references\/([^/]+)$/);
    if (referenceMatch && request.method === "GET") {
      const record = await getReference(env, decodeURIComponent(referenceMatch[1]));
      return record ? json(record) : json({ error: "record_not_found" }, 404);
    }
    if (url.pathname === "/api/decisions" && request.method === "POST") {
      return saveDecision(request, env, reviewer);
    }
    return json({ error: "not_found" }, 404);
  }
};
