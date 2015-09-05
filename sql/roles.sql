CREATE role superusers WITH SUPERUSER;
CREATE role guest;

-- Roles

BEGIN;

GRANT ALL on SCHEMA djet TO superusers;
GRANT ALL ON ALL TABLES IN SCHEMA djet TO superusers;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA djet TO superusers;
GRANT ALL ON ALL SEQUENCES IN SCHEMA djet TO superusers;
GRANT USAGE on SCHEMA global TO superusers;
GRANT SELECT,INSERT,UPDATE ON global.session TO superusers;
GRANT ALL ON ALL TABLES IN SCHEMA pg_catalog TO superusers;
GRANT ALL ON pg_authid TO superusers;

GRANT USAGE on SCHEMA djet TO guest;
GRANT SELECT ON ALL TABLES IN SCHEMA djet TO guest;
GRANT INSERT,UPDATE ON djet.data_node TO guest;
GRANT ALL ON ALL SEQUENCES IN SCHEMA djet TO guest;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA djet TO guest;
GRANT USAGE on SCHEMA global TO guest;
GRANT SELECT,INSERT,UPDATE ON global.session TO guest;
GRANT SELECT ON pg_authid TO guest;

COMMIT;
