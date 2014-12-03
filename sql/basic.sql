-- Basic Jet basetypes and nodes

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('basic', 0.01, 'Basic features');

-- Basetypes

INSERT INTO basetype (feature_id, name,title) VALUES (1, 'domain','Domain');
INSERT INTO basetype (feature_id, name,title) VALUES (1, 'directory','Directory');
INSERT INTO basetype (feature_id, name,title,datacolumns,template) VALUES (1, 'textpage','Text Page','[{"name":"text","title":"Text","type":"Html"}]','<domain>/basetype/text.tx');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'basetype','Jet Basetype','Djet::Engine::Basetype','[{"name":"text","title":"Text","type":"Str"},{"name":"parent","type":"Int"}]');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'djet_config', 'Jet Configuration','Djet::Engine::Config','[{"name":"topmenu","title":"Topmenu","type":"Boolean"}]');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'djet_tree', 'Node Tree','Djet::Engine::ConfigTree','[{"name":"topmenu","title":"Topmenu","type":"Boolean"}]');
INSERT INTO basetype (feature_id, name,title,handler,datacolumns) VALUES (1, 'login', 'Login','Djet::Engine::Login','[
	{"name":"username","title":"User","type":"Str", "required": "on"},
	{"name":"password","title":"Password","type":"Protected", "required": "on"}
]');

-- Data Nodes

INSERT INTO data_node (basetype_id,part,name,title,datacolumns) VALUES (1,'','Root','Root','{}');
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,1,'djet','Jet Base Directory','Jet Base Directory','{}','{"superusers":["read"]}' FROM basetype WHERE name='domain';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,2,'basetype','Jet Configuration - Basetypes', 'Jet Configuration - Basetypes','{"topmenu":"on"}','{"superusers":["read"]}' FROM basetype WHERE name='basetype';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,2,'node','Jet Configuration', 'Jet Configuration','{}','{"superusers":["read"]}' FROM basetype WHERE name='djet_config';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns,acl) SELECT id,2,'tree','nodetree', 'Node Tree','{"topmenu":"on"}','{"superusers":["read"]}' FROM basetype WHERE name='djet_tree';

INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT id,1,'login','login', 'Login','{}' FROM basetype WHERE name='login';

-- Global

CREATE SCHEMA global;

SET search_path=global, public;

CREATE TABLE sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

COMMIT;
