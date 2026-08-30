# PostgreSQL Backup and Monitoring

Runnable PostgreSQL lab with automated logical backups, restore verification and Prometheus metrics through postgres_exporter.

## Start

```bash
docker compose config
docker compose up -d
docker compose ps
docker compose exec postgres psql -U app -d app -c 'select now();'
curl --fail http://localhost:9187/metrics | head
```

## Create sample data

```bash
docker compose exec postgres psql -U app -d app <<'SQL'
create table if not exists orders(id bigserial primary key, created_at timestamptz default now());
insert into orders default values;
select * from orders;
SQL
```

## Backup

```bash
chmod +x scripts/*.sh
./scripts/backup.sh
ls -lh backups/
sha256sum -c backups/*.sha256
```

The script uses `pg_dump`, gzip compression, SHA-256 checksums, a stable `latest.sql.gz` symlink and configurable retention.

## Restore verification

```bash
./scripts/restore-check.sh backups/latest.sql.gz
```

The restore check creates a temporary database, restores with `ON_ERROR_STOP`, runs a validation query and removes the temporary database. A successful backup job is not sufficient without this test.

## Scheduling example

```cron
15 2 * * * cd /opt/postgresql-backup && BACKUP_DIR=/srv/backups ./scripts/backup.sh
```

Use systemd timers in environments where job status must be visible through systemd.

## Monitoring

Important signals include exporter availability, connection utilization, transaction rate, replication lag, database size, deadlocks and backup age.

## Troubleshooting

- empty backup: inspect database selection and pg_dump errors;
- restore failure: verify PostgreSQL version compatibility and checksum;
- exporter down: test its connection string from the Compose network;
- disk growth: review retention and include backup storage in capacity monitoring.

Production backups should be encrypted, copied off-host, access-controlled and tested regularly against documented recovery objectives.
