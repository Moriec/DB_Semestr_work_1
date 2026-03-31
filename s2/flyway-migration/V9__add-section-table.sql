-- 1. RANGE
CREATE TABLE autoservice_schema.purchase_range (
    id SERIAL,
    provider_id INT,
    date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    value DECIMAL(100, 2),
    PRIMARY KEY (id, date)
) PARTITION BY RANGE (date);

CREATE TABLE autoservice_schema.purchase_2024 PARTITION OF autoservice_schema.purchase_range
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE autoservice_schema.purchase_2025 PARTITION OF autoservice_schema.purchase_range
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE autoservice_schema.purchase_2026 PARTITION OF autoservice_schema.purchase_range
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

INSERT INTO autoservice_schema.purchase_range (date, value)
SELECT 
    '2024-01-01'::timestamp + (random() * (interval '3 years')), 
    (random() * 1000)::decimal(10,2)
FROM generate_series(1, 100000) s(i);

CREATE INDEX ON autoservice_schema.purchase_range (date);


-- 2. LIST
CREATE TABLE autoservice_schema.payout_list (
    id SERIAL,
    value INT NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    payout_type VARCHAR NOT NULL,
    worker_id INT,
    PRIMARY KEY (id, payout_type)
) PARTITION BY LIST (payout_type);

CREATE TABLE autoservice_schema.payout_salary PARTITION OF autoservice_schema.payout_list
    FOR VALUES IN ('salary');

CREATE TABLE autoservice_schema.payout_bonus PARTITION OF autoservice_schema.payout_list
    FOR VALUES IN ('bonus');

CREATE TABLE autoservice_schema.payout_other PARTITION OF autoservice_schema.payout_list
    FOR VALUES IN ('other');

INSERT INTO autoservice_schema.payout_list (value, date, payout_type, worker_id)
SELECT 
    (random() * 100000)::int, 
    now() - (random() * (interval '1 year')), 
    (ARRAY['salary', 'bonus', 'other'])[floor(random() * 3) + 1],
    (random() * 100)::int
FROM generate_series(1, 100000) s(i);

CREATE INDEX ON autoservice_schema.payout_list (payout_type);


-- 3. HASH
CREATE TABLE autoservice_schema.customer_hash (
    id INT NOT NULL,
    full_name VARCHAR NOT NULL,
    phone_number VARCHAR NOT NULL,
    PRIMARY KEY (id)
) PARTITION BY HASH (id);

CREATE TABLE autoservice_schema.customer_h1 PARTITION OF autoservice_schema.customer_hash
    FOR VALUES WITH (MODULUS 3, REMAINDER 0);

CREATE TABLE autoservice_schema.customer_h2 PARTITION OF autoservice_schema.customer_hash
    FOR VALUES WITH (MODULUS 3, REMAINDER 1);

CREATE TABLE autoservice_schema.customer_h3 PARTITION OF autoservice_schema.customer_hash
    FOR VALUES WITH (MODULUS 3, REMAINDER 2);

INSERT INTO autoservice_schema.customer_hash (id, full_name, phone_number)
SELECT 
    i, 
    'Customer Full Name ' || i, 
    '8-999-' || floor(random() * 900 + 100)::text || '-' || floor(random() * 9000 + 1000)::text
FROM generate_series(1, 100000) s(i);
