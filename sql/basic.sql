-- Basic data tables

BEGIN;

SET search_path TO data;

CREATE TABLE directory (
	id						int NOT NULL PRIMARY KEY
							REFERENCES jet.node
							ON DELETE cascade
							ON UPDATE cascade
);

CREATE VIEW directory_view AS
SELECT
	d.*,
	b.name basetype,
	n.title,
	p.id path_id, p.part,p.node_path,parent_id
FROM
	directory d
JOIN
	jet.node n USING (id)
JOIN
	jet.path p ON p.node_id=n.id
JOIN
	jet.basetype b ON basetype_id = b.id
WHERE
    b.name='directory';

CREATE TRIGGER directory_view_insert INSTEAD OF INSERT ON directory_view FOR EACH ROW EXECUTE PROCEDURE jet.data_view_insert();

COMMIT;