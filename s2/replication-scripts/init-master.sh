#!/bin/bash
set -e

# Добавляем разрешение на репликацию для пользователя replication_user
echo "host replication replication_user 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
echo "host auto_db replication_user 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"

# Перезагружаем конфиг, если это не первый запуск (хотя в /docker-entrypoint-initdb.d/ это выполнится при создании)
pg_ctl reload
