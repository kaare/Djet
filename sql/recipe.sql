-- Djet basetypes and nodes for the Recipe Feature

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('recipe', 0.01, 'Recipe features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,template) VALUES (currval('feature_id_seq'), 'recipe','Recipe','[ {"name":"ingredients","title":"Ingredients","type":"Html", "required": "on", "searchable":"on"}, {"name":"procedure","title":"Procedure","type":"Html", "required": "on", "searchable":"on"}, {"name":"image","title":"Image Path","type":"File"}, {"name":"persons","title":"Persons","type":"Int", "searchable":"on"}, {"name":"category","title":"Category","type":"Str", "searchable":"on"}, {"name":"main_indredient","title":"Main Ingredient","type":"Str", "searchable":"on"}, {"name":"occasion","title":"Occasion","type":"Str", "searchable":"on"}, {"name":"remarks","title":"Remarks","type":"Str", "searchable":"on"}, {"name":"publish_date","title":"Publish Date","type":"Date", "required": "on", "searchable":"on"}, {"name":"tags","title":"Tags","type":"Str", "searchable":"on"}, {"name":"keywords","title":"Keywords","type":"Str", "searchable":"on"} ]'
,'<domain>/basetype/recipe.tx');


COMMIT;
