# Raw data (not versioned)

Place immutable originals under `paris/` and `ehis/`. Their README files are
versioned, but Git ignores all data placed below them. Preserve provider filenames and record provenance, receipt date,
licence, checksum and version in `data/metadata/source_manifest.csv`.

On Ubuntu, `PARISEHIS_RAW_DIR` may point to protected storage outside the repo.
Never write transformed files here.
