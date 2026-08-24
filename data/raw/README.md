# Raw data (not versioned)

Place immutable microdata under `paris/` and `ehis/`. Store source documents
whose redistribution rights have not been confirmed under
`documentation/<survey>/`. The README files are versioned, but Git ignores all
data placed below this directory. Preserve the provider filename, local filename,
provenance, receipt date, licence, checksum and version in
`data/metadata/source_manifest.csv` or an associated processing note.

On Ubuntu, `PARISEHIS_RAW_DIR` may point to protected storage outside the repo.
Never write transformed files here.
