CREATE USER replication_user WITH REPLICATION PASSWORD '1234';
SELECT * FROM pg_create_physical_replication_slot('replica_1_slot');
SELECT * FROM pg_create_physical_replication_slot('replica_2_slot');
