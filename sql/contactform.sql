-- Jet basetypes and nodes for the Contactform Feature

BEGIN;

SET search_path=jet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('contactform', 0.01, 'Contactform features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,handler,template) VALUES (currval('feature_id_seq'), 'contactforms','Contact Form','Jet::Engine::Contactform','/basetype/contactform.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler) VALUES (currval('feature_id_seq'), 'contactform','Contact Form','[
	{"name":"company","title":"Company","type":"Str"},
	{"name":"name","title":"Name","type":"Str", "required": "on"},
	{"name":"street","title":"Address","type":"Str"},
	{"name":"postalcode","title":"Postal Code","type":"Int"},
	{"name":"city","title":"City","type":"Str"},
	{"name":"phone","title":"Telephone","type":"Str", "required": "on"},
	{"name":"email","title":"Email Address","type":"Email", "required": "on"},
	{"name":"comment","title":"Comment","type":"Html", "required": "on"}]','Jet::Engine::Contactform');

-- Data Nodes

-- INSERT INTO data_node (basetype_id,parent_id,part,name,title) VALUES (currval('basetype_id_seq'),1,'contactform','contactform','Contact Form');

COMMIT;
