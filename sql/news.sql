-- Jet basetypes and nodes for the News Feature

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('news', 0.01, 'News features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler) VALUES (currval('feature_id_seq'), 'news','News','[
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]','Djet::Engine::News');
INSERT INTO basetype (feature_id,name,title,datacolumns,template) VALUES (currval('feature_id_seq'), 'news-item','News Item','[
	{"name":"news_text","title":"Text","type":"Html"}
]','<domain>/basetype/news_item.tx');

-- Data Nodes

-- INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) VALUES (currval('basetype_id_seq'),1,'news','news','News','{"topmenu":"on"}');

COMMIT;
