SET search_path=jet;

INSERT INTO basetype (name) VALUES ('domain');
INSERT INTO basetype (name) VALUES ('directory');
INSERT INTO basetype (name) VALUES ('usergroup');
INSERT INTO basetype (name,parent,searchable,columns) VALUES ('person','{2,3}','{"userlogin"}','{"userlogin","password"}');
INSERT INTO basetype (name,parent) VALUES ('photoalbum','{3,4}'); -- Photoalbums belong to users, but can be assigned to groups
INSERT INTO basetype (name,parent,columns,searchable) VALUES ('photo','{5}','{"filename","metadata","contenttype"}','{"filename","metadata"}');

INSERT INTO node (basetype_id,part,name,title) VALUES (1,'','family_photo','Family Photo');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (2,'groups','User Groups', 1, 'Groups');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (3,'users', 'All Users', 2, 'All Users');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (3,'rasmussen', 'Rasmussens', 2, 'Rasmussen Family');
INSERT INTO node (basetype_id,part,title,parent_id,name,columns) VALUES (4,'kaare', 'Kaare', 4, 'Kaare Rasmussen','{"kaare","test"}');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (5,'scratch', 'Scratchpad', 5, 'Kaare Scratchpad');
-- UPDATE node SET workalbum_id=6 WHERE id=5;
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (5,'trash', 'Trash', 5, 'Trash');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (5,'kaare', 'Test album', 5, 'Test album');
--
INSERT INTO node (basetype_id,part,title,parent_id,name,columns) VALUES (4,'fely', 'Fely', 4, 'Fely Rasmussen','{"fely","test"}');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (5,'scratch', 'Scratchpad', 9, 'Fely Scratchpad');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (5,'trash', 'Trash', 9, 'Trash');
INSERT INTO node (basetype_id,part,title,parent_id,name) VALUES (5,'fely', 'Fely test album', 9, 'Fely test album');
