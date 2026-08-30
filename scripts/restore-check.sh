#!/usr/bin/env bash
set -euo pipefail
file="${1:?usage: restore-check.sh BACKUP.sql.gz}"
test_db="restore_check"
docker compose exec -T postgres dropdb -U app --if-exists "$test_db"
docker compose exec -T postgres createdb -U app "$test_db"
gzip -dc "$file" | docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U app -d "$test_db"
docker compose exec -T postgres psql -U app -d "$test_db" -c "SELECT current_database(), now();"
docker compose exec -T postgres dropdb -U app "$test_db"
