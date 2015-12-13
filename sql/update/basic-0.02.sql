-- Basic Djet basetypes and nodes

BEGIN;

SET search_path=djet, public;

-- Features

UPDATE feature SET version = 0.02 WHERE name='basic';

-- Basetypes

INSERT INTO basetype (feature_id, name,title,datacolumns) VALUES (1, 'directory','Directory','[{"name":"topmenu","title":"Topmenu","type":"Boolean"}]');
UPDATE basetype SET datacolumns='[ {"name":"topmenu","title":"Topmenu","type":"Boolean"}, {"name":"children","title":"Children","type":"Str"}, {"name":"order","title":"Sort Order","type":"Str"}, {"name":"search","title":"Search Options","type":"Str"}, {"name":"pagination","title":"Pagination","type":"Str"}, {"name":"listname","title":"List Name","type":"Str"}, {"name":"listname","title":"List Name","type":"Str"} ]' WHERE feature_id = 1 AND name = 'directory';
