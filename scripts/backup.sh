#!/usr/bin/env bash
set -euo pipefail
backup_dir="${BACKUP_DIR:-backups}"
retention_days="${RETENTION_DAYS:-7}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$backup_dir"
file="$backup_dir/postgres-$timestamp.sql.gz"
docker compose exec -T postgres pg_dump -U app -d app --no-owner --no-acl | gzip -9 > "$file"
sha256sum "$file" > "$file.sha256"
ln -sfn "$(basename "$file")" "$backup_dir/latest.sql.gz"
find "$backup_dir" -type f -mtime "+$retention_days" -delete
echo "$file"
