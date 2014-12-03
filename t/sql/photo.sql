-- Family::Photo

BEGIN;

SET search_path TO data;

CREATE TABLE domain (
	id						int NOT NULL PRIMARY KEY
	                        REFERENCES djet.node
							ON DELETE cascade
							ON UPDATE cascade);

CREATE OR REPLACE VIEW domain_view AS
SELECT
	d.*,
	n.name, n.title,
	b.name basetype,
	p.id path_id, p.part,p.node_path,parent_id
FROM
	data.domain d
JOIN
	djet.node n USING (id)
JOIN
	djet.path p ON p.node_id=n.id
JOIN
	djet.basetype b ON basetype_id = b.id
WHERE
    b.name='domain';

CREATE TRIGGER domain_view_insert INSTEAD OF INSERT ON domain_view FOR EACH ROW EXECUTE PROCEDURE djet.data_view_insert();

--

CREATE TABLE photoalbum (
	id						int NOT NULL PRIMARY KEY
							REFERENCES djet.node
							ON DELETE cascade
							ON UPDATE cascade
);

CREATE OR REPLACE VIEW photoalbum_view AS
SELECT
	d.*,
	b.name basetype,
	n.name, n.title,
	p.id path_id, p.part,p.node_path,parent_id
FROM
	photoalbum d
JOIN
	djet.node n USING (id)
JOIN
	djet.path p ON p.node_id=n.id
JOIN
	djet.basetype b ON basetype_id = b.id
WHERE
    b.name='photoalbum';

CREATE TRIGGER photoalbum_view_insert INSTEAD OF INSERT ON photoalbum_view FOR EACH ROW EXECUTE PROCEDURE djet.data_view_insert();

--

CREATE TABLE photo (
	id						 int NOT NULL PRIMARY KEY
	                         REFERENCES djet.node
									 ON DELETE cascade
									 ON UPDATE cascade,
	content_type			 text,
	metadata				 text
);

CREATE VIEW photo_view AS
SELECT
	d.*,
	b.name basetype,
	n.name, n.title,
	p.id path_id, p.part,p.node_path,parent_id
FROM
	photo d
JOIN
	djet.node n USING (id)
JOIN
	djet.path p ON p.node_id=n.id
JOIN
	djet.basetype b ON basetype_id = b.id
WHERE
    b.name='photo';

CREATE TRIGGER photo_view_insert INSTEAD OF INSERT ON photo_view FOR EACH ROW EXECUTE PROCEDURE djet.data_view_insert();

COMMIT;