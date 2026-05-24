# Read-Only External State

Never modify external systems (AWS S3, databases, cloud storage, APIs) without explicit permission.

- AWS S3: `s3 ls`, `s3 cp` (download), `s3 presign` are OK. `s3 cp` (upload), `s3 rm`, `s3 mv`, `s3 sync --delete` are NOT without asking.
- Same principle for any cloud storage, database, or external API with write capabilities.
- Fetch, download, and read are always fine. Create, update, delete require explicit user consent.
- When in doubt, ask before writing to anything outside the local filesystem.
