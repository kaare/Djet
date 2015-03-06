-- Djet basetypes and nodes for the Blog Feature

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('blog', 0.01, 'Blog features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'blogs','Blogs','[
	{"type":"Boolean","title":"Menu","name":"topmenu"}
]','Djet::Engine::Blog','<domain>/basetype/blogs.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'blog','Blog','[
	{"name":"teaser","title":"Teaser","type":"Html"},
	{"name":"content_text","title":"Text","type":"Html", "required": "on"},
	{"name":"status","title":"Status","type":"Enum", "required": "on", "default": ["unpublished","published","scheduled"]},
	{"name":"publish_date","title":"Publish Date","type":"Date", "required": "on"},
	{"name":"tags","title":"Tags","type":"Str"},
	{"name":"keywords","title":"Keywords","type":"Str"}
]','Djet::Engine::Blog','<domain>/basetype/blog.tx');
INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'blog_reply','Reply','[
	{"name":"username","title":"Name","type":"Str", "required": "on"},
	{"name":"email","title":"Email Address","type":"Email", "required": "on"},
	{"name":"subject","title":"Subject","type":"Str", "required": "on"},
	{"name":"comment","title":"Comment","type":"Text", "required": "on"}
]','Djet::Engine::Blog','<domain>/basetype/blog_reply.tx');


COMMIT;
