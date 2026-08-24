-- Private review data for Cloudflare D1. Do not place licensed abstracts in
-- the public Pages build. Access is expected to be enforced by Cloudflare Access.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS reviewers (
  reviewer_id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  access_subject TEXT UNIQUE,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('REVIEWER', 'ADJUDICATOR', 'ADMIN')),
  active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS review_records (
  record_id TEXT PRIMARY KEY,
  public_reference_id TEXT,
  source_database TEXT NOT NULL,
  source_id TEXT NOT NULL,
  pmid TEXT,
  title TEXT NOT NULL,
  abstract_text TEXT,
  doi TEXT,
  journal TEXT,
  publication_year INTEGER,
  source_url TEXT,
  stage TEXT NOT NULL CHECK (stage IN ('TITLE_ONLY', 'TITLE_ABSTRACT')),
  access_class TEXT NOT NULL CHECK (access_class IN ('PUBLIC', 'RESTRICTED')),
  duplicate_of TEXT REFERENCES review_records(record_id),
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS reviewer_decisions (
  record_id TEXT NOT NULL REFERENCES review_records(record_id),
  reviewer_id TEXT NOT NULL REFERENCES reviewers(reviewer_id),
  decision TEXT NOT NULL CHECK (decision IN ('INCLUDE', 'BACKGROUND', 'EXCLUDE')),
  reason_code TEXT,
  notes TEXT,
  decided_at TEXT NOT NULL,
  revision INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY (record_id, reviewer_id, revision)
);

CREATE TABLE IF NOT EXISTS adjudications (
  record_id TEXT PRIMARY KEY REFERENCES review_records(record_id),
  final_decision TEXT NOT NULL CHECK (final_decision IN ('INCLUDE', 'BACKGROUND', 'EXCLUDE')),
  adjudicator_id TEXT NOT NULL REFERENCES reviewers(reviewer_id),
  rationale TEXT NOT NULL,
  adjudicated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS model_runs (
  model_run_id TEXT PRIMARY KEY,
  method TEXT NOT NULL,
  model_name TEXT NOT NULL,
  model_version TEXT NOT NULL,
  criteria_version TEXT NOT NULL,
  prompt_or_config_hash TEXT NOT NULL,
  training_cutoff TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS model_assessments (
  model_run_id TEXT NOT NULL REFERENCES model_runs(model_run_id),
  record_id TEXT NOT NULL REFERENCES review_records(record_id),
  proposed_decision TEXT NOT NULL CHECK (proposed_decision IN ('INCLUDE', 'BACKGROUND', 'EXCLUDE')),
  relevance_probability REAL,
  rationale TEXT,
  PRIMARY KEY (model_run_id, record_id)
);

CREATE INDEX IF NOT EXISTS idx_decisions_reviewer ON reviewer_decisions(reviewer_id, record_id);
CREATE INDEX IF NOT EXISTS idx_records_duplicate ON review_records(duplicate_of);
