## 1. Секционирование (Partitioning)

### а) RANGE Partitioning (Секционирование по диапазону)

**Запрос для анализа:**
```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM autoservice_schema.purchase_range 
WHERE date >= '2025-01-01' AND date < '2026-01-01';
```

![alt text](image-13.png)




### б) LIST Partitioning (Секционирование по списку)

**Запрос для анализа:**
```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM autoservice_schema.payout_list 
WHERE payout_type = 'salary';
```

![alt text](image-14.png)




### в) HASH Partitioning (Секционирование по хешу)

**Запрос для анализа:**
```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM autoservice_schema.customer_hash 
WHERE id = 42;
```

![alt text](image-15.png)



## 2. Секционирование и физическая репликация

### а) Проверить что секционирование есть на репликах

```bash
docker exec -it pg_replica_1 psql -U postgres -d auto_db -c "
SELECT 
    nmsp_parent.nspname AS parent_schema,
    parent.relname      AS parent_table,
    nmsp_child.nspname  AS child_schema,
    child.relname       AS child_table
FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid  = child.oid
    JOIN pg_namespace nmsp_parent   ON nmsp_parent.oid       = parent.relnamespace
    JOIN pg_namespace nmsp_child    ON nmsp_child.oid        = child.relnamespace
WHERE parent.relname = 'purchase_range';"
```


![alt text](image-16.png)

---

## 3. Логическая репликация и секционирование

### а) publish_via_partition_root = off 

```sql
ALTER PUBLICATION my_publication ADD TABLE autoservice_schema.purchase_range;
ALTER PUBLICATION my_publication SET (publish_via_partition_root = false);
```

```bash
docker exec -it pg_logical_replica psql -U postgres -d auto_db -c "
CREATE TABLE autoservice_schema.purchase_range (
    id SERIAL,
    provider_id INT,
    date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    value DECIMAL(100, 2),
    PRIMARY KEY (id, date)
);"
```

```sql
INSERT INTO autoservice_schema.purchase_range (date, value) VALUES ('2025-05-10', 999.00);
```

```bash
docker logs pg_logical_replica --tail 20
```
![alt text](image-17.png)

---

### б) Вариант 2: publish_via_partition_root = on

```sql
ALTER PUBLICATION my_publication SET (publish_via_partition_root = true);
```

```sql
INSERT INTO autoservice_schema.purchase_range (date, value) VALUES ('2025-06-15', 777.00);
```


```bash
docker exec -it pg_logical_replica psql -U postgres -d auto_db -c "SELECT * FROM autoservice_schema.purchase_range WHERE value = 777.00;"
```

![alt text](image-18.png)

---

## 4. Шардирование через postgres_fdw

### а) Реализация шардирования

в миграциях

### c) Простой запрос на все данные

```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM autoservice_schema.order_sharded;
```

![alt text](image-19.png)

### d) Простой запрос на шард

```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT * FROM autoservice_schema.order_sharded WHERE customer_id = 10;
```

![alt text](image-20.png)


