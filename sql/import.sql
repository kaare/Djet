-- Jet basetypes and nodes for the Import Feature

BEGIN;

SET search_path=jet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('import', 0.01, 'Import features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler,template) VALUES (currval('feature_id_seq'), 'import','Import Page','[
	{"name":"path","title":"Path","type":"Str"},
	{"name":"queue","title":"Queue","type":"Str"},
	{"name":"topmenu","title":"Topmenu","type":"Boolean"}
]','Jet::Engine::Import','basetype/import.tx');
INSERT INTO basetype (feature_id, name,title,datacolumns,handler) VALUES (currval('feature_id_seq'), 'upload', 'Uploaded File','[
	{"name":"mime_type","title":"Mime Type","type":"Str"}
]','Jet::Engine::Import::File');

-- Data Nodes

-- INSERT INTO data_node (basetype_id,parent_id,part,name,title,datacolumns) SELECT id,1,'import','Import','Import Data','{"path":"private/files","topmenu":"on"}' FROM basetype WHERE name="import";

COMMIT;
