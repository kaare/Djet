-- Basic Jet basetypes and nodes

BEGIN;

SET search_path=jet, public;

-- Basetypes

INSERT INTO basetype (name) VALUES ('directory');
INSERT INTO basetype (name) VALUES ('jet_config');
INSERT INTO basetype (name, handler,datacolumns) VALUES ('jet_basetype','Jet::Engine::Basetype','[{"name":"name","type":"Str", "traits": ["Jet::Trait::Config::Basetype"]},{"name":"parent","type":"Int"}]');
INSERT INTO basetype (name) VALUES ('not_found');
INSERT INTO basetype (name) VALUES ('usergroup');
INSERT INTO basetype (name,parent,datacolumns,searchable) VALUES ('person','{2,3}', '[{"name":"userlogin","type":"Str"},{"name":"password","type":"Password"}]', '{"userlogin"}');
INSERT INTO basetype (name,datacolumns) VALUES ('acl', '[{"name":"acl","type":"Str"}]');

-- Data Nodes

INSERT INTO data_node (basetype_id,part,name,title) VALUES (1,'','Root','Root Directory');
INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (1,1,'jet','Jet Base Directory','Jet Base Directory');
INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (2, 2,'config','Jet Configuration', 'Jet Configuration');
INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (3, 3,'basetype','Jet Configuration - Basetypes', 'Jet Configuration - Basetypes');
INSERT INTO data_node (basetype_id,part,name,title) VALUES (4,'not_found','not_found','Not Found');

INSERT INTO data_node (basetype_id,part,name,datacolumns) VALUES (6,'read','read','{read}');
INSERT INTO data_node (basetype_id,part,name,datacolumns) VALUES (6,'write','write','{write}');

COMMIT;
