-- Basic Jet basetypes and nodes

BEGIN;

SET search_path=jet;

-- Engines

INSERT INTO engine (name) VALUES ('default');
INSERT INTO engine (name) VALUES ('basetype');


-- Basetypes

INSERT INTO basetype (name) VALUES ('directory');
INSERT INTO basetype (name) VALUES ('jet_config');
INSERT INTO basetype (name, engines,columns) VALUES ('jet_basetype','{2}','[{"name":"name","type":"Str"},{"name":"parent","type":"Int"}]');
INSERT INTO basetype (name) VALUES ('not_found');
INSERT INTO basetype (name) VALUES ('usergroup');
INSERT INTO basetype (name,parent,columns,searchable) VALUES ('person','{2,3}', '[{"name":"userlogin","type":"Str"},{"name":"password","type":"Password"}]', '{"userlogin"}');

-- Data Nodes

INSERT INTO data_node (basetype_id,part,name,title) VALUES (1,'','Root','Root Directory');
INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (1,1,'jet','Jet Base Directory','Jet Base Directory');
INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (2, 2,'config','Jet Configuration', 'Jet Configuration');
INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (3, 3,'basetype','Jet Configuration - Basetypes', 'Jet Configuration - Basetypes');
INSERT INTO data_node (basetype_id,part,name,title) VALUES (4,'not_found','not_found','Not Found');

COMMIT;