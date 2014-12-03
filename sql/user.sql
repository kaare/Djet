-- Djet basetypes and nodes for handling users

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('user', 0.01, 'User features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'users','Users','[
	{"type":"Structured","title":"Roles","name":"roles"},
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]','Djet::Engine::User','<domain>/basetype/users.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'user','User','[
	{"name":"handle","title":"Handle","type":"Str", "required": "on"},
	{"name":"password","title":"Password","type":"Protected", "required": "on", "storage":false},
	{"name":"username","title":"User Name","type":"Str", "required": "on"},
	{"name":"street","title":"Address","type":"Str"},
	{"name":"postalcode","title":"Postal Code","type":"Int"},
	{"name":"city","title":"City","type":"Str"},
	{"name":"phone","title":"Telephone","type":"Str", "required": "on"},
	{"name":"email","title":"Email Address","type":"Email", "required": "on"},
	{"name":"comment","title":"Comment","type":"Text"}
]','Djet::Engine::User','<domain>/basetype/user.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'mypage','My Page','[
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]','Djet::Engine::User','<domain>/basetype/mypage.tx');

COMMIT;
