-- Basic Jet basetypes and nodes

BEGIN;

SET search_path=jet;

-- Basetypes

INSERT INTO basetype (name) VALUES ('directory');
INSERT INTO basetype (name) VALUES ('jet_config');
INSERT INTO basetype (name) VALUES ('jet_basetype');
INSERT INTO basetype (name) VALUES ('not_found');
INSERT INTO basetype (name) VALUES ('usergroup');
INSERT INTO basetype (name,parent,searchable,columns) VALUES ('person','{2,3}','{"userlogin"}','{"userlogin","password"}');

-- Data Nodes

INSERT INTO data_node (basetype_id,part,name,title) VALUES (1,'','Root','Root Directory');
INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (1,1,'jet','Jet Base Directory','Jet Base Directory');
INSERT INTO data_node (basetype_id,parent_id,part,title,name) VALUES (2, 2,'config','Jet Configuration', 'Jet Configuration');
INSERT INTO data_node (basetype_id,parent_id,part,title,name) VALUES (3, 3,'basetype','Jet Configuration - Basetypes', 'Jet Configuration - Basetypes');
INSERT INTO data_node (basetype_id,part,name,title) VALUES (4,'not_found','not_found','Not Found');

COMMIT;