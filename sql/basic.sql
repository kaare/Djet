-- Basic Jet basetypes and nodes

BEGIN;

SET search_path=jet;

-- Basetypes

INSERT INTO basetype (name) VALUES ('jet_config');
INSERT INTO basetype (name) VALUES ('jet_basetype');
INSERT INTO basetype (name) VALUES ('directory');
INSERT INTO basetype (name) VALUES ('usergroup');

-- Data Nodes

INSERT INTO data_node (basetype_id,part,name,title) VALUES (2,'jet','Jet Base Directory','Jet Base Directory');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (1,'config','Jet Configuration', 1, 'Jet Configuration');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (1,'basetype','Jet Configuration - Basetypes', 2, 'Jet Configuration - Basetypes');
INSERT INTO basetype (name,parent,searchable,columns) VALUES ('person','{2,3}','{"userlogin"}','{"userlogin","password"}');

COMMIT;