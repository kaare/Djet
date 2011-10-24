SET search_path=jet;

INSERT INTO basetype (name) VALUES ('domain');
INSERT INTO basetype (name) VALUES ('directory');
INSERT INTO basetype (name) VALUES ('usergroup');
INSERT INTO basetype (name,parent) VALUES ('person','{2,3}');
INSERT INTO basetype (name,parent) VALUES ('photoalbum','{3,4}'); -- Photoalbums belong to users, but can be assigned to groups
INSERT INTO basetype (name,parent, searchable) VALUES ('photo','{5}', '{"filename","metadata"}');

SET search_path=data;

INSERT INTO domain_view (part,domainname,title) VALUES ('','family_photo','Family Photo');

INSERT INTO directory_view (part,title,parent_id,directoryname) VALUES ('groups','User Groups', 1, 'Groups');

INSERT INTO usergroup_view (part,title,parent_id,groupname) VALUES ('users', 'All Users', 2, 'All Users');
INSERT INTO usergroup_view (part,title,parent_id,groupname) VALUES ('rasmussen', 'Rasmussens', 2, 'Rasmussen Family');

INSERT INTO person_view (part,title,parent_id,username,userlogin,password) VALUES ('kaare', 'Kaare', 4, 'Kaare Rasmussen','kaare', 'test');
INSERT INTO jet.path (parent_id,part,node_id) VALUES (3,'kaare',5);

INSERT INTO photoalbum_view (part,title,parent_id,albumname) VALUES ('scratch', 'Scratchpad', 5, 'Kaare Scratchpad');
UPDATE person SET workalbum_id=6 WHERE id=5
;
INSERT INTO photoalbum_view (part,title,parent_id,albumname) VALUES ('trash', 'Trash', 5, 'Trash');

INSERT INTO photoalbum_view (part,title,parent_id,albumname) VALUES ('kaare', 'Test album', 5, 'Test album');

--
INSERT INTO person_view (part,title,parent_id,username,userlogin,password) VALUES ('fely', 'Fely', 4, 'Fely Rasmussen', 'fely', 'test');

INSERT INTO photoalbum_view (part,title,parent_id,albumname) VALUES ('scratch', 'Scratchpad', 9, 'Fely Scratchpad');
INSERT INTO photoalbum_view (part,title,parent_id,albumname) VALUES ('trash', 'Trash', 9, 'Trash');

INSERT INTO photoalbum_view (part,title,parent_id,albumname) VALUES ('fely', 'Fely test album', 9, 'Fely test album');

INSERT INTO jet.path (parent_id,part,node_id) VALUES (4,'kaare_album',8);