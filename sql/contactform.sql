-- Djet basetypes and nodes for the Contactform Feature

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('contactform', 0.01, 'Contactform features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'contactforms','Contact Form','[
	{"name":"from","title":"From","type":"Email", "required": "on"},
	{"name":"recipient","title":"Recipient","type":"Email", "required": "on"},
	{"name":"receipt_msg","title":"Receipy Message","type":"Str", "required": "on"},
	{"name":"template","title":"Template","type":"Str", "required": "on"},
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]','Djet::Engine::Contactform','<domain>/basetype/contactform.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'contactform','Contact Form','[
	{"name":"company","title":"Company","type":"Str"},
	{"name":"username","title":"Name","type":"Str", "required": "on"},
	{"name":"street","title":"Address","type":"Str"},
	{"name":"postalcode","title":"Postal Code","type":"Int"},
	{"name":"city","title":"City","type":"Str"},
	{"name":"phone","title":"Telephone","type":"Str", "required": "on"},
	{"name":"email","title":"Email Address","type":"Email", "required": "on"},
	{"name":"comment","title":"Comment","type":"Text", "required": "on"}
]','Djet::Engine::Contactform','<domain>/basetype/contactform.tx');

-- Data Nodes

-- INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) VALUES (currval('basetype_id_seq'),1,'contactform','contactform','Contact Form','{"from":"test@test.test","recipient":"test@test.test","template":"/basetype/contactform.tx"}');

COMMIT;
