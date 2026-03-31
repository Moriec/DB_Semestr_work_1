-- 1. Включаем расширение postgres_fdw на роутере
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 2. Создаем серверы для шардов
-- Примечание: host=pg_shard_1 и pg_shard_2 - это имена контейнеров в сети Docker
CREATE SERVER shard_1_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'pg_shard_1', port '5432', dbname 'auto_db');

CREATE SERVER shard_2_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'pg_shard_2', port '5432', dbname 'auto_db');

-- 3. Создаем пользовательские маппинги
-- Для простоты используем пользователя postgres
CREATE USER MAPPING FOR postgres
    SERVER shard_1_server
    OPTIONS (user 'postgres', password '1234');

CREATE USER MAPPING FOR postgres
    SERVER shard_2_server
    OPTIONS (user 'postgres', password '1234');

-- 4. Создаем родительскую шардированную таблицу (на роутере)
-- ВАЖНО: Убираем PRIMARY KEY, так как FDW не поддерживает уникальные индексы на шардированных таблицах
CREATE TABLE autoservice_schema.order_sharded (
    id INT NOT NULL,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2)
) PARTITION BY HASH (customer_id);

-- 5. Создаем внешние таблицы-партиции, указывая на соответствующие шарды
CREATE FOREIGN TABLE autoservice_schema.order_shard_1
    PARTITION OF autoservice_schema.order_sharded
    FOR VALUES WITH (MODULUS 2, REMAINDER 0)
    SERVER shard_1_server
    OPTIONS (schema_name 'autoservice_schema', table_name 'order_shard_1');

CREATE FOREIGN TABLE autoservice_schema.order_shard_2
    PARTITION OF autoservice_schema.order_sharded
    FOR VALUES WITH (MODULUS 2, REMAINDER 1)
    SERVER shard_2_server
    OPTIONS (schema_name 'autoservice_schema', table_name 'order_shard_2');
