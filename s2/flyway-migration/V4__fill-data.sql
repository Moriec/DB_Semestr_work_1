INSERT INTO autoservice_schema.branch_office (address, phone_number)
SELECT
    'Address ' || i,
    '+79' || floor(random() * 900000000 + 100000000)::text
FROM generate_series(1, 10) i;

INSERT INTO autoservice_schema.provider (address, phone_number)
SELECT
    'Provider Addr ' || i,
    '+79' || floor(random() * 900000000 + 100000000)::text
FROM generate_series(1, 50) i;

INSERT INTO autoservice_schema.worker (full_name, role, phone_number, id_branch_office)
SELECT
    'Worker ' || i,
    (ARRAY['Mechanic', 'Manager', 'Cleaner'])[floor(random()*3 + 1)],
    '+79' || floor(random() * 900000000 + 100000000)::text,
    floor(random() * 10 + 1)
FROM generate_series(1, 100) i;

INSERT INTO autoservice_schema.box (id_branch_office, box_type)
SELECT
    floor(random() * 10 + 1),
    (ARRAY['Lift', 'Pit', 'Paint'])[floor(random()*3 + 1)]
FROM generate_series(1, 30) i;

INSERT INTO autoservice_schema.customer (full_name, phone_number, tags)
SELECT
    'Customer ' || i,
    '+79' || floor(random() * 900000000 + 100000000)::text,
    CASE
        WHEN rnd < 0.1 THEN NULL
        WHEN rnd < 0.4 THEN ARRAY['New']
        WHEN rnd < 0.7 THEN ARRAY['Regular', 'VIP']
        ELSE ARRAY['Inactive']
        END
FROM (
         SELECT generate_series(1, 250000) as i, random() as rnd
     ) sub;

INSERT INTO autoservice_schema.car (vin, model, plate_number, status, box_id, specs)
SELECT
    lpad(i::text, 17, '0'),
    'Model ' || floor(random() * 100),
    'A' || floor(random() * 999)::text || 'AA' || floor(random() * 99)::text,
    (ARRAY['In Service', 'Waiting', 'Ready'])[floor(random()*3 + 1)],
    floor(random() * 30 + 1),
    jsonb_build_object(
        'color', (ARRAY['Red', 'Blue', 'Black'])[floor(random()*3 + 1)],
        'year', floor(random() * 20 + 2000)
    )
FROM generate_series(1, 250000) i;

INSERT INTO autoservice_schema.purchase (provider_id, date, value, discount_period)
SELECT
    floor(pow(random(), 2) * 50 + 1),
    NOW() - (random() * 365) * interval '1 day',
    (random() * 10000)::decimal(10,2),
    daterange(current_date, current_date + floor(random() * 30)::int)
FROM generate_series(1, 250000) i;

INSERT INTO autoservice_schema."order" (customer_id, creation_date, description, meta_info)
SELECT
    floor(random() * 250000 + 1),
    NOW() - (random() * 365) * interval '1 day',
    'Order description ' || i,
    jsonb_build_object('priority', floor(random() * 5))
FROM generate_series(1, 300000) i;

INSERT INTO autoservice_schema.order_closure_date (order_id, closure_date)
SELECT
    id,
    creation_date + (random() * 10) * interval '1 day'
FROM autoservice_schema."order"
WHERE random() < 0.8;

INSERT INTO autoservice_schema.task (order_id, value, worker_id, description, car_id)
SELECT
    floor(random() * 300000 + 1),
    (random() * 5000)::decimal(10,2),
    floor(random() * 100 + 1),
    'Fixing part ' || floor(random() * 1000) || ' issue',
    lpad(floor(random() * 250000 + 1)::text, 17, '0')
FROM generate_series(1, 400000) i;

UPDATE autoservice_schema.task
SET description_search = to_tsvector('english', description);

INSERT INTO autoservice_schema.autopart (name, purchase_id, task_id)
SELECT
    'Part ' || i,
    floor(random() * 250000 + 1),
    NULL
FROM generate_series(1, 250000) i;

UPDATE autoservice_schema.autopart
SET task_id = i
    FROM generate_series(1, 100000) i
WHERE autopart.id = i;

select * from autoservice_schema.branch_office;