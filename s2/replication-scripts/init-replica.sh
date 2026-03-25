#!/bin/bash
set -e

# Wait for master to be ready
until pg_isready -h pg_master -p 5432 -U postgres; do
  echo "Waiting for master..."
  sleep 2
done

# If data directory is empty, perform base backup
if [ -z "$(ls -A $PGDATA)" ]; then
  echo "Performing base backup from master..."
  pg_basebackup -h pg_master -D $PGDATA -U replication_user -v -P -X stream --slot=$REPLICA_SLOT
  
  # Configure standby
  echo "primary_conninfo = 'host=pg_master port=5432 user=replication_user password=1234'" >> "$PGDATA/postgresql.conf"
  echo "primary_slot_name = '$REPLICA_SLOT'" >> "$PGDATA/postgresql.conf"
  touch "$PGDATA/standby.signal"
fi

# Start Postgres
exec docker-entrypoint.sh postgres
