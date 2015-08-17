-- Djet basetypes and nodes for handling Job::Machine entries

BEGIN;

SET search_path=djet, public;

-- Features

INSERT INTO feature (name,version, description) VALUES ('jobmachine', 0.01, 'Job::Machine features');

-- Basetypes

INSERT INTO basetype (feature_id,name,title,datacolumns,handler) VALUES (currval('feature_id_seq'), 'jobmachine','Job::Machine','[
	{"name":"topmenu","title":"Topmenu","type":"Boolean"}
]','Djet::Engine::Admin::Jobmachibe');

-- Data Nodes

-- Tables from Job::Machine should be installed

COMMIT;
