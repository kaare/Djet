-- Djet basetypes and nodes for the Import / Export Feature

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('import', 0.01, 'Import features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'import','Import Page','[
	{"name":"path","title":"Path","type":"Str"},
	{"name":"queue","title":"Queue","type":"Str"},
	{"name":"topmenu","title":"Topmenu","type":"Boolean"}
]','Djet::Engine::Import','basetype/import.tx');
INSERT INTO basetype (feature_id, name,title,datacolumns,handler) VALUES (currval('feature_id_seq'), 'upload', 'Uploaded File','[
	{"name":"file_path","title":"File Path","type":"Str"},
	{"name":"mime_type","title":"Mime Type","type":"Str"}
]','Djet::Engine::Import::File');

-- Export

INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'export','Export Page','[
	{"name":"queue","title":"Queue","required":"on","type":"Str"},
	{"type":"Boolean","title":"Topmenu","name":"topmenu","required":"on"}
]','Djet::Engine::Export','basetype/export.tx');

-- Data Nodes

-- INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT id,1,'import','Import','Import Data','{"path":"private/files","topmenu":"on"}' FROM basetype WHERE name="import";

COMMIT;
