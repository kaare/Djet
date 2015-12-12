-- Djet basetypes and nodes for the Recipe Feature

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('recipe', 0.01, 'Recipe features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,template) VALUES (currval('feature_id_seq'), 'recipe','Recipe','[
	{"name":"ingredients","title":"Ingredients","type":"Html", "required": "on"},
	{"name":"procedure","title":"Procedure","type":"Html", "required": "on"},
	{"name":"image","title":"Image Path","type":"File"},
	{"name":"persons","title":"Persons","type":"Int"},
	{"name":"category","title":"Category","type":"Str"},
	{"name":"main_indredient","title":"Main Ingredient","type":"Str"},
	{"name":"occasion","title":"Occasion","type":"Str"},
	{"name":"remarks","title":"Remarks","type":"Str"},
	{"name":"publish_date","title":"Publish Date","type":"Date", "required": "on"},
	{"name":"tags","title":"Tags","type":"Str"},
	{"name":"keywords","title":"Keywords","type":"Str"}
]','<domain>/basetype/recipe.tx');


COMMIT;
