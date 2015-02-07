-- Basic Djet basetypes and nodes

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('Djet.xyz', 0.01, 'Djet.xyz features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,handler,datacolumns) VALUES (currval('feature_id_seq'),'frontpage','Front Page','Djet::Engine::Default','[
	{"type":"Html","title":"Content","name":"content_text"},
	{"type":"Str","title":"Image","name":"image"},
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]');

INSERT INTO basetype (feature_id,name,title,handler,datacolumns) VALUES (currval('feature_id_seq'),'documentation','Documentation','Djetsite::Engine::Pod','[
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]');

UPDATE basetype SET datacolumns = '[
	{"name":"username","title":"Name","type":"Str", "required": "on"},
	{"name":"phone","title":"Telephone","type":"Str", "required": "on"},
	{"name":"email","title":"Email Address","type":"Email", "required": "on"},
	{"name":"comment","title":"Comment","type":"Text", "required": "on"}
]' WHERE name='contactform';

-- Datanodes

UPDATE data_node SET basetype_id = 1,
	name='www.djet.xyz',
	title='Home',
	datacolumns='{"redirect":"index.html"}' WHERE parent_id IS NULL;

INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.node_id,'index.html','frontpage','Home of Djet','{"content_text":"Djet.xyz", "image":"img/private_djet.jpg"}' FROM basetype b, data_node n WHERE b.name='frontpage' AND n.name='www.djet.xyz';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.node_id,'about','about','About','{"text":"About this","topmenu":"on"}' FROM basetype b, data_node n WHERE b.name='textpage' AND n.name='www.djet.xyz';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.node_id,'documentation','Documentation','Documentation','{"topmenu":"on"}' FROM basetype b, data_node n WHERE b.name='documentation' AND n.name='www.djet.xyz';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.node_id,'blogs','blogs','Blogs','{"text":"All the blogs","topmenu":"on"}' FROM basetype b, data_node n WHERE b.name='blogs' AND n.name='www.djet.xyz';
INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT b.id,n.node_id,'contactform','contactform','Contact','{"from":"test@test.test","recipient":"test@test.test","template":"/basetype/contactform.tx","topmenu":"on"}' FROM basetype b, data_node n WHERE b.name='contactforms' AND n.name='www.djet.xyz';

COMMIT;
