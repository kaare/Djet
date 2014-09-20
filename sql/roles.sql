BEGIN;

-- Roles

CREATE role superusers SUPERUSER;
GRANT ALL on SCHEMA jet TO superusers;
GRANT ALL ON ALL TABLES IN SCHEMA jet TO superusers;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA jet TO superusers;
GRANT USAGE on SCHEMA global TO superusers;
GRANT SELECT,INSERT,UPDATE ON global.sessions TO superusers;
GRANT ALL ON ALL TABLES IN SCHEMA pg_catalog TO superusers;

CREATE role guest;
GRANT USAGE on SCHEMA jet TO guest;
GRANT SELECT ON ALL TABLES IN SCHEMA jet TO guest;
GRANT INSERT,UPDATE ON jet.data_node TO guest;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA jet TO guest;
GRANT USAGE on SCHEMA global TO guest;
GRANT SELECT,INSERT,UPDATE ON global.sessions TO guest;

COMMIT;
