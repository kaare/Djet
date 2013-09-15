-- Public functions

CREATE LANGUAGE plperl;
CREATE extension ltree;

BEGIN;

CREATE FUNCTION set_modified () RETURNS "trigger" AS $$
BEGIN
	NEW.created = OLD.created;
	NEW.modified = now();
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- jet schema

CREATE SCHEMA jet;

SET search_path TO jet, public;

CREATE TABLE basetype (
	id					serial NOT NULL PRIMARY KEY,
	name					text UNIQUE,
	parent					int[],
	datacolumns				json,
	searchable				text[],
	handler					text,
	template				text,
	created					timestamp default now(),
	modified				timestamp
);

COMMENT ON TABLE basetype IS 'Node Base Type';
COMMENT ON COLUMN basetype.name IS 'Base Name';
COMMENT ON COLUMN basetype.parent IS 'Array of allowed parent basetypes';
COMMENT ON COLUMN basetype.datacolumns IS 'The column definitions';
COMMENT ON COLUMN basetype.searchable IS 'The searchable columns';
COMMENT ON COLUMN basetype.handler IS 'The handler module';
COMMENT ON COLUMN basetype.template IS 'The template for this basetype';

CREATE TRIGGER set_modified BEFORE UPDATE ON basetype FOR EACH ROW EXECUTE PROCEDURE public.set_modified();

CREATE TABLE data (
	id					serial NOT NULL PRIMARY KEY,
	basetype_id				int NOT NULL REFERENCES basetype(id)
							ON DELETE restrict
							ON UPDATE restrict,
	name					text,
	title					text,
	datacolumns				text[],
	fts					tsvector,
	created					timestamp default now(),
	modified				timestamp
);

COMMENT ON TABLE data IS 'Data';
COMMENT ON COLUMN data.basetype_id IS 'The Basetype of the Data';
COMMENT ON COLUMN data.name IS 'The name';
COMMENT ON COLUMN data.title IS 'The Title';
COMMENT ON COLUMN data.datacolumns IS 'The actual column data';
COMMENT ON COLUMN data.fts IS 'Full Text Search column containing the content of the searchable columns';

CREATE TRIGGER set_modified BEFORE UPDATE ON data FOR EACH ROW EXECUTE PROCEDURE public.set_modified();

CREATE TABLE node (
	id					serial NOT NULL PRIMARY KEY,
	data_id					int REFERENCES data(id)
							ON DELETE cascade
							ON UPDATE cascade,
	parent_id				int REFERENCES node(id)
							ON DELETE cascade
							ON UPDATE cascade,
	part					text,
	node_path				ltree,
	created					timestamp default now(),
	modified				timestamp
);

COMMENT ON TABLE node IS 'Node';
COMMENT ON COLUMN node.parent_id IS 'Pointer to the data row';
COMMENT ON COLUMN node.parent_id IS 'Parent of this uri';
COMMENT ON COLUMN node.part IS 'Path part';
COMMENT ON COLUMN node.node_path IS 'Global Path parts';

CREATE TRIGGER set_modified BEFORE UPDATE ON node FOR EACH ROW EXECUTE PROCEDURE public.set_modified();

CREATE INDEX node_path_gist_idx ON node USING GIST (node_path);

--
-- data_node view
--

CREATE VIEW data_node AS
SELECT d.id data_id, d.basetype_id, d.name, d.title, d.datacolumns, d.fts, d.created data_created, d.modified data_modified,
	n.id node_id, n.parent_id, n.part, n.node_path, n.created node_created, n.modified	node_modified
FROM jet.data d
JOIN jet.node n ON d.id=n.data_id;

CREATE OR REPLACE FUNCTION data_node_insert() RETURNS trigger AS $$
DECLARE
BEGIN
	WITH new_data AS (
		INSERT INTO jet.data (basetype_id, name, title, datacolumns, fts) VALUES (NEW.basetype_id, NEW.name, NEW.title, NEW.datacolumns, NEW.fts) RETURNING id
	)
	INSERT INTO jet.node (data_id, parent_id, part, node_path) SELECT id, NEW.parent_id, NEW.part, NEW.node_path FROM new_data;
	RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER data_node_insert INSTEAD OF INSERT ON data_node FOR EACH ROW EXECUTE PROCEDURE jet.data_node_insert();

CREATE OR REPLACE FUNCTION data_node_update() RETURNS trigger AS $$
DECLARE
BEGIN
	UPDATE jet.data
		SET basetype_id=NEW.basetype_id, name=NEW.name, title=NEW.title, datacolumns=NEW.datacolumns, fts=NEW.fts
		WHERE id=OLD.data_id;
	UPDATE jet.node
		SET parent_id=NEW.parent_id, part=NEW.part, node_path=NEW.node_path
		WHERE id=OLD.node_id;
	RETURN NEW;
END;
$$ language plpgsql;

CREATE TRIGGER data_node_update INSTEAD OF UPDATE ON data_node FOR EACH ROW EXECUTE PROCEDURE jet.data_node_update();

CREATE OR REPLACE FUNCTION get_calculated_node_path(param_id integer) RETURNS ltree AS
$$
	SELECT CASE
		WHEN s.parent_id IS NULL THEN text2ltree(regexp_replace(s.part, '\W', '_', 'g'))
		ELSE jet.get_calculated_node_path(s.parent_id) || regexp_replace(s.part, '\W', '_', 'g')
	END
	FROM jet.node s
	WHERE s.id = $1;
$$
LANGUAGE sql;

--
-- Update the node path recursively down the tree
--

CREATE OR REPLACE FUNCTION trig_update_node_path() RETURNS trigger AS
$$
BEGIN
	IF TG_OP = 'UPDATE' THEN
		IF (COALESCE(OLD.parent_id,0) != COALESCE(NEW.parent_id,0) OR NEW.data_id != OLD.data_id OR NEW.part != OLD.part) THEN
			-- update all nodes that are children of this one including this one
			UPDATE jet.node SET node_path = jet.get_calculated_node_path(id)
				WHERE node_path @> node.node_path;
		END IF;
	ELSIF TG_OP = 'INSERT' THEN
		UPDATE jet.node SET node_path = jet.get_calculated_node_path(NEW.id) WHERE node.id = NEW.id;
	END IF;
   RETURN NEW;
END
$$
LANGUAGE 'plpgsql' VOLATILE;

CREATE TRIGGER trig01_update_node_path
	AFTER INSERT OR UPDATE OF data_id, parent_id, part
	ON node
	FOR EACH ROW EXECUTE PROCEDURE trig_update_node_path();

COMMIT;
