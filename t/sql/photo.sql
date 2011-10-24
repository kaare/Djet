-- Family::Photo

BEGIN;

SET search_path TO data;

CREATE TABLE domain (
	id						int NOT NULL PRIMARY KEY
	                        REFERENCES jet.node
							ON DELETE cascade
							ON UPDATE cascade,
	domainname				text
);

CREATE OR REPLACE VIEW domain_view AS
SELECT
	d.*,
	n.title,
	p.id path_id, p.part,p.node_path,parent_id
FROM
	data.domain d
JOIN
	jet.node n USING (id)
JOIN
	jet.path p ON p.node_id=n.id
JOIN
	jet.basetype b ON basetype_id = b.id
WHERE
    b.name='domain';

CREATE TRIGGER domain_view_insert INSTEAD OF INSERT ON domain_view FOR EACH ROW EXECUTE PROCEDURE jet.data_view_insert();

--

CREATE TABLE photoalbum (
	id						int NOT NULL PRIMARY KEY
							REFERENCES jet.node
							ON DELETE cascade
							ON UPDATE cascade,
	albumname				text
);

CREATE OR REPLACE VIEW photoalbum_view AS
SELECT
	d.*,
	n.title,
	p.id path_id, p.part,p.node_path,parent_id
FROM
	photoalbum d
JOIN
	jet.node n USING (id)
JOIN
	jet.path p ON p.node_id=n.id
JOIN
	jet.basetype b ON basetype_id = b.id
WHERE
    b.name='photoalbum';

CREATE TRIGGER photoalbum_view_insert INSTEAD OF INSERT ON photoalbum_view FOR EACH ROW EXECUTE PROCEDURE jet.data_view_insert();

--

CREATE TABLE photo (
	id						 int NOT NULL PRIMARY KEY
	                         REFERENCES jet.node
									 ON DELETE cascade
									 ON UPDATE cascade,
	filename				 text,
	content_type			 text,
	metadata				 text
);

CREATE VIEW photo_view AS
SELECT
	d.*,
	n.title,
	p.id path_id, p.part,p.node_path,parent_id
FROM
	photo d
JOIN
	jet.node n USING (id)
JOIN
	jet.path p ON p.node_id=n.id
JOIN
	jet.basetype b ON basetype_id = b.id
WHERE
    b.name='photo';

CREATE TRIGGER photo_view_insert INSTEAD OF INSERT ON photo_view FOR EACH ROW EXECUTE PROCEDURE jet.data_view_insert();

COMMIT;