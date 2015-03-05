-- Basic Djet basetypes and nodes

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('basic', 0.01, 'Basic features');

-- Basetypes

INSERT INTO basetype (feature_id, name,title,datacolumns) VALUES (1, 'domain','Domain','[{"name":"redirect","title":"Redirect","type":"Str"}]');
INSERT INTO basetype (feature_id, name,title,datacolumns) VALUES (1, 'directory','Directory','[{"name":"topmenu","title":"Topmenu","type":"Boolean"}]');
INSERT INTO basetype (feature_id, name,title,datacolumns,template) VALUES (1, 'textpage','Text Page','[{"name":"text","title":"Text","type":"Html"},{"name":"topmenu","title":"Topmenu","type":"Boolean"}]','<domain>/basetype/text.tx');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'basetype','Djet Basetype','Djet::Engine::Admin::Basetype','[{"name":"text","title":"Text","type":"Str"},{"name":"parent","type":"Int"}]');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'djet_config', 'Djet Configuration','Djet::Engine::Admin::Config','[{"name":"topmenu","title":"Topmenu","type":"Boolean"}]');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'djet_tree', 'Node Tree','Djet::Engine::Admin::ConfigTree','[{"name":"topmenu","title":"Topmenu","type":"Boolean"}]');

-- Data Nodes

INSERT INTO data_node (basetype_id,part,name,title,datacolumns) VALUES (1,'','Root','Root','{}');
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,1,'djet','Djet Base Directory','Djet Base Directory','{}','{"superusers":["read"]}' FROM basetype WHERE name='domain';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,2,'basetype','Djet Configuration - Basetypes', 'Djet Configuration - Basetypes','{"topmenu":"on"}','{"superusers":["read"]}' FROM basetype WHERE name='basetype';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,2,'node','Djet Configuration', 'Djet Configuration','{}','{"superusers":["read"]}' FROM basetype WHERE name='djet_config';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,2,'tree','nodetree', 'Node Tree','{"topmenu":"on"}','{"superusers":["read"]}' FROM basetype WHERE name='djet_tree';

-- Global

CREATE SCHEMA global;

SET search_path=global, public;

CREATE TABLE sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

COMMIT;
