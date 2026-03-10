## Gin

~~~sql
-- 1. Поиск по массиву 
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.customer WHERE tags @> ARRAY['VIP'];
CREATE INDEX gin_customer_tags ON autoservice_schema.customer USING GIN (tags);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.customer WHERE tags @> ARRAY['VIP'];
~~~
![img_2.png](images/img_2.png)

![img_2.png](images/img_2_1.png)

~~~sql
-- 2. Поиск по ключу в JSONB
EXPLAIN ANALYZE SELECT vin FROM autoservice_schema.car WHERE specs @> '{"color": "Red"}';
CREATE INDEX gin_car_specs ON autoservice_schema.car USING GIN (specs);
EXPLAIN ANALYZE SELECT vin FROM autoservice_schema.car WHERE specs @> '{"color": "Red"}';
~~~
![img_3.png](images/img_3.png)

![img_4.png](images/img_4.png)

~~~sql
-- 3. Поиск по JSONB
EXPLAIN ANALYZE SELECT id FROM autoservice_schema."order" WHERE meta_info @> '{"priority": 1}';
CREATE INDEX gin_order_meta ON autoservice_schema."order" USING GIN (meta_info jsonb_path_ops);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema."order" WHERE meta_info @> '{"priority": 1}';
~~~

![img_5.png](images/img_5.png)

![img_6.png](images/img_6.png)

~~~sql
-- 4. Полнотекстовый поиск по tsvector 
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.task WHERE description_search @@ to_tsquery('english', 'fix');
CREATE INDEX gin_task_fts ON autoservice_schema.task USING GIN (description_search);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.task WHERE description_search @@ to_tsquery('english', 'fix');
~~~

![img_7.png](images/img_7.png)

![img_8.png](images/img_8.png)

~~~sql
-- 5. Проверка существования ключа в JSONB
EXPLAIN ANALYZE SELECT vin FROM autoservice_schema.car WHERE specs ? 'color';
CREATE INDEX gin_car_specs_keys ON autoservice_schema.car USING GIN (specs jsonb_ops);
EXPLAIN ANALYZE SELECT vin FROM autoservice_schema.car WHERE specs ? 'color';
~~~

![img_9.png](images/img_9.png)

![img_10.png](images/img_10.png)

![img_11.png](images/img_11.png)

## Gist

~~~sql
-- Поиск по пересечению диапазонов
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.purchase WHERE discount_period && daterange('2026-03-01', '2026-03-31');
CREATE INDEX gist_purch_dates ON autoservice_schema.purchase USING GIST (discount_period);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.purchase WHERE discount_period && daterange('2026-03-01', '2026-03-31');
~~~

![img_12.png](images/img_12.png)

![img_13.png](images/img_13.png)

~~~sql
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.purchase WHERE discount_period @> current_date;
CREATE INDEX gist_purch_dates_contain ON autoservice_schema.purchase USING GIST (discount_period);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.purchase WHERE discount_period @> current_date;
~~~

![img_14.png](images/img_14.png)

![img_15.png](images/img_15.png)

~~~sql
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.customer WHERE full_name LIKE '%Customer 150%';
CREATE INDEX gist_cust_name ON autoservice_schema.customer USING GIST (full_name gist_trgm_ops);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.customer WHERE full_name LIKE '%Customer 150%';
~~~

![img_16.png](images/img_16.png)

![img_17.png](images/img_17.png)

~~~sql
CREATE INDEX gist_task_fts ON autoservice_schema.task USING GIST (description_search);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.task WHERE description_search @@ to_tsquery('english', 'issue');
~~~

![img_18.png](images/img_18.png)

![img_19.png](images/img_19.png)

~~~sql
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.task WHERE value BETWEEN 1000 AND 2000;
CREATE INDEX gist_task_val ON autoservice_schema.task USING GIST (value);
EXPLAIN ANALYZE SELECT id FROM autoservice_schema.task WHERE value BETWEEN 1000 AND 2000;
~~~

![img_20.png](images/img_20.png)

![img_21.png](images/img_21.png)

![img_22.png](images/img_22.png)

## JOIN

~~~sql
-- 1. Nested Loop
EXPLAIN ANALYZE
SELECT * FROM autoservice_schema.branch_office b
JOIN autoservice_schema.worker w ON b.id = w.id_branch_office;
~~~

![img_23.png](images/img_23.png)

~~~sql
-- 2. Hash Join 
EXPLAIN ANALYZE
SELECT * FROM autoservice_schema.task t
JOIN autoservice_schema.car c ON t.car_id = c.vin;
~~~

![img_24.png](images/img_24.png)

~~~sql
-- 3. Merge Join 
EXPLAIN ANALYZE
SELECT * FROM autoservice_schema.task t
JOIN autoservice_schema."order" o ON t.order_id = o.id
ORDER BY t.order_id;
~~~

![img_25.png](images/img_25.png)

~~~sql
-- 4. LEFT JOIN
EXPLAIN ANALYZE
SELECT o.id, c.closure_date
FROM autoservice_schema."order" o
LEFT JOIN autoservice_schema.order_closure_date c ON o.id = c.order_id;
~~~

![img_26.png](images/img_26.png)

~~~sql
-- 5. Множественный JOIN 
EXPLAIN ANALYZE
SELECT c.full_name, t.description
FROM autoservice_schema.customer c
JOIN autoservice_schema."order" o ON c.id = o.customer_id
JOIN autoservice_schema.task t ON o.id = t.order_id
LIMIT 100;
~~~

![img_27.png](images/img_27.png)



![img_2.png](img_2.png)