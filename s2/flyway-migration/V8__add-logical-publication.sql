CREATE PUBLICATION my_publication FOR TABLE autoservice_schema.customer;


GRANT USAGE ON SCHEMA autoservice_schema TO replication_user;
GRANT SELECT ON ALL TABLES IN SCHEMA autoservice_schema TO replication_user;
