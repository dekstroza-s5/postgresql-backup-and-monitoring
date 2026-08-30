# PostgreSQL Backup and Monitoring

Automated logical backups, restore verification and Prometheus metrics for PostgreSQL.

```bash
cp .env.example .env
docker compose up -d
./scripts/backup.sh
./scripts/restore-check.sh backups/latest.sql.gz
```

Backups are compressed, checksummed and retained for a configurable number of days. A backup is only useful after a successful restore test.
