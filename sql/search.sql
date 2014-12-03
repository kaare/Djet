-- Jet basetypes and nodes for the Search Feature

BEGIN;

SET search_path=jet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('search', 0.01, 'Search features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler) VALUES (currval('feature_id_seq'), 'search','Search Page','[
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]','Djet::Engine::Search');

-- Data Nodes

-- INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (currval('basetype_id_seq'),1,'search','Search','Search Data');

COMMIT;
