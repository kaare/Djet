INSERT INTO jet.basetype (name) VALUES ('domain');
INSERT INTO jet.basetype (name,parent) VALUES ('directory','{1}');
INSERT INTO jet.basetype (name,parent, searchable) VALUES ('file','{2}', '{"filename","metadata"}');

-- SET search_path=jet,public;

-- INSERT INTO basetype (name) VALUES ('domain');
-- INSERT INTO node (basetype_id) VALUES (1);
-- INSERT INTO path (part,node_id) VALUES ('/',1);
-- INSERT INTO path (parent_id,part,node_id) VALUES (1,'test',1);
