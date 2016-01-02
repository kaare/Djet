-- Basic Djet basetypes and nodes

BEGIN;

SET search_path=djet, public;

-- Features

UPDATE feature SET version = 0.02 WHERE name='basic';

-- Basetypes

UPDATE basetype SET
	datacolumns = '[
		{"name":"topmenu","title":"Topmenu","type":"Boolean"},
		{"name":"children","title":"Children","type":"Str"},
		{"name":"order","title":"Sort Order","type":"Str"},
		{"name":"search","title":"Search Options","type":"Str"},
		{"name":"pagination","title":"Pagination","type":"Str"},
		{"name":"listname","title":"List Name","type":"Str"}
	]',
	handler = 'Djet::Engine::Directory'
	WHERE feature_id = 1 AND name = 'directory';

COMMIT;
