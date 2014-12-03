SET search_path=djet, public;

INSERT INTO basetype (name) VALUES ('domain');
INSERT INTO basetype (name) VALUES ('directory');
INSERT INTO basetype (name) VALUES ('usergroup');
INSERT INTO basetype (name,parent,searchable,datacolumns) VALUES ('person','{2,3}','{"userlogin"}','["userlogin","password"]');
INSERT INTO basetype (name,parent) VALUES ('photoalbum','{3,4}'); -- Photoalbums belong to users, but can be assigned to groups
INSERT INTO basetype (name,parent,datacolumns,searchable) VALUES ('photo','{5}','["filename","metadata","contenttype"]','{"filename","metadata"}');

INSERT INTO data_node (basetype_id,part,name,title) VALUES (1,'','family_photo','Family Photo');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (2,'groups','User Groups', 1, 'Groups');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (3,'users', 'All Users', 2, 'All Users');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (3,'rasmussen', 'Rasmussens', 2, 'Rasmussen Family');
INSERT INTO data_node (basetype_id,part,title,parent_id,name,datacolumns) VALUES (4,'kaare', 'Kaare', 4, 'Kaare Rasmussen','{"kaare","test"}');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (5,'scratch', 'Scratchpad', 5, 'Kaare Scratchpad');
-- UPDATE data_node SET workalbum_id=6 WHERE id=5;
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (5,'trash', 'Trash', 5, 'Trash');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (5,'kaare', 'Test album', 5, 'Test album');
--
INSERT INTO data_node (basetype_id,part,title,parent_id,name,datacolumns) VALUES (4,'fely', 'Fely', 4, 'Fely Rasmussen','{"fely","test"}');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (5,'scratch', 'Scratchpad', 9, 'Fely Scratchpad');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (5,'trash', 'Trash', 9, 'Trash');
INSERT INTO data_node (basetype_id,part,title,parent_id,name) VALUES (5,'fely', 'Fely test album', 9, 'Fely test album');
