--

BEGIN;

SET search_path TO data;

CREATE TABLE person (
	id						int NOT NULL PRIMARY KEY
							REFERENCES jet.node
							ON DELETE cascade
							ON UPDATE cascade,
	username				text,
	userlogin				text,
	password				text,
	workalbum_id			int REFERENCES jet.node
);

CREATE VIEW person_view AS
SELECT
	d.*,
	n.title,
	p.part,p.node_path,parent_id
FROM
	person d
JOIN
	jet.node n USING (id)
JOIN
	jet.path p ON p.node_id=n.id
JOIN
	jet.basetype b ON basetype_id = b.id
WHERE
    b.name='person';

CREATE TRIGGER person_view_insert INSTEAD OF INSERT ON person_view FOR EACH ROW EXECUTE PROCEDURE jet.data_view_insert();

--

CREATE TABLE usergroup (
	id						int NOT NULL PRIMARY KEY
							REFERENCES jet.node
							ON DELETE cascade
							ON UPDATE cascade,
	groupname				text
);

CREATE VIEW usergroup_view AS
SELECT
	d.*,
	n.title,
	p.part,p.node_path,parent_id
FROM
	usergroup d
JOIN
	jet.node n USING (id)
JOIN
	jet.path p ON p.node_id=n.id
JOIN
	jet.basetype b ON basetype_id = b.id
WHERE
    b.name='usergroup';

CREATE TRIGGER usergroup_view_insert INSTEAD OF INSERT ON usergroup_view FOR EACH ROW EXECUTE PROCEDURE jet.data_view_insert();

COMMIT;