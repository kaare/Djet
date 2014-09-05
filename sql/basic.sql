-- Basic Jet basetypes and nodes

BEGIN;

SET search_path=jet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('basic', 0.01, 'Basic features');

-- Basetypes

INSERT INTO basetype (feature_id, name,title) VALUES (1, 'domain','Domain');
INSERT INTO basetype (feature_id, name,title) VALUES (1, 'directory','Directory');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'basetype','Jet Basetype','Jet::Engine::Basetype','[{"name":"text","type":"Str"},{"name":"parent","type":"Int"}]');
INSERT INTO basetype (feature_id, name,title,handler) VALUES (1, 'jet_config', 'Jet Configuration','Jet::Engine::Config');

-- Data Nodes

INSERT INTO data_node (basetype_id,part,name,title,datacolumns) VALUES (1,'','Root','Root','{}');
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) VALUES (2,1,'jet','Jet Base Directory','Jet Base Directory','{}');
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) VALUES (3,2,'basetype','Jet Configuration - Basetypes', 'Jet Configuration - Basetypes','{}');
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) VALUES (4,2,'node','Jet Configuration', 'Jet Configuration','{}');
-- INSERT INTO data_node (basetype_id,part,name,title,datacolumns) VALUES (4,'not_found','not_found','Not Found','{}');

-- INSERT INTO data_node (basetype_id,part,name,datacolumns) VALUES (6,'read','read','{read}');
-- INSERT INTO data_node (basetype_id,part,name,datacolumns) VALUES (6,'write','write','{write}');

COMMIT;
