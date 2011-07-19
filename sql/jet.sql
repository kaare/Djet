-- Public functions

CREATE LANGUAGE plperl;

BEGIN;

CREATE FUNCTION set_modified () RETURNS "trigger" AS $$
BEGIN
	NEW.created = OLD.created;
	NEW.modified = now();
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;

-- jet schema

CREATE SCHEMA jet;
SET search_path TO jet;

BEGIN;

CREATE TABLE basetype (
	id						 serial NOT NULL PRIMARY KEY,
	name					 text UNIQUE,
	parent					 int[],
	created					 timestamp default now(),
	modified				 timestamp
);

COMMENT ON TABLE basetype IS 'Node Base Type';
COMMENT ON COLUMN basetype.name IS 'Base Name';
COMMENT ON COLUMN basetype.parent IS 'Array of allowed parent basetypes';

CREATE TRIGGER set_modified BEFORE UPDATE ON basetype FOR EACH ROW EXECUTE PROCEDURE public.set_modified();

CREATE TABLE node (
	id						 serial NOT NULL PRIMARY KEY,
	basetype_id				 int REFERENCES basetype(id)
							 ON DELETE restrict
							 ON UPDATE restrict,
	title					 text,
	created					 timestamp default now(),
	modified				 timestamp
);

COMMENT ON TABLE node IS 'Node';
COMMENT ON COLUMN node.basetype_id IS 'The Basetype of the Node';

CREATE TRIGGER set_modified BEFORE UPDATE ON node FOR EACH ROW EXECUTE PROCEDURE public.set_modified();

CREATE TABLE path (
	id						 serial NOT NULL PRIMARY KEY,
	parent_id				 int REFERENCES path(id)
							 ON DELETE restrict
							 ON UPDATE restrict,
	part					 text,
	node_path				 text[],
	node_id					 int REFERENCES node,
	created					 timestamp default now(),
	modified				 timestamp,
	UNIQUE (parent_id, part),
	UNIQUE (node_path)
);

CREATE INDEX idx_path_gin_idx ON path USING gin(node_path);

COMMENT ON TABLE path IS 'Node path';
COMMENT ON COLUMN path.parent_id IS 'Parent of this uri';
COMMENT ON COLUMN path.node_path IS 'Path part';
COMMENT ON COLUMN path.node_path IS 'Global Path parts';
COMMENT ON COLUMN path.node_id IS 'The actual Node';

CREATE TRIGGER set_modified BEFORE UPDATE ON path FOR EACH ROW EXECUTE PROCEDURE public.set_modified();

-- Views

CREATE OR REPLACE VIEW nodepath AS
	SELECT
		b.name base_type, b.id basetype_id, b.parent,
		n.title,
		p.id path_id, p.parent_id, p.part, p.node_path, p.node_id
	FROM
		path p
	LEFT JOIN
		node n
	ON
		p.node_id=n.id
	LEFT JOIN
		basetype b
	ON
		n.basetype_id=b.id
;

-- Functions

CREATE OR REPLACE FUNCTION data_view_insert() RETURNS trigger AS $$
	my ($base_name) = split '_', $_TD->{relname} or return SKIP;

	my $q = "SELECT id FROM jet.basetype WHERE name = ".quote_literal($base_name);
	my $rv = spi_exec_query($q);
	unless ($rv->{status} eq 'SPI_OK_SELECT' and $rv->{processed} == 1) {
		elog(ERROR,"Basetype $base_name not found in jet.basetype");
		return SKIP;
	}

	my $data;
	$data->{$_} = $_TD->{new}{$_} for keys %{ $_TD->{new} };
	my $base_id = $rv->{rows}->[0]->{id};
	$q = "INSERT INTO jet.node (basetype_id, title) VALUES ($base_id, ".quote_nullable($data->{title}).") RETURNING id";
	$rv = spi_exec_query($q);
	return SKIP unless $rv->{status} eq 'SPI_OK_INSERT_RETURNING' and $rv->{processed} == 1;

	my $node_id = $rv->{rows}->[0]->{id};
	$q = qq{INSERT INTO "jet"."path" (node_id, parent_id, part) VALUES ($node_id, } 
		. quote_nullable($data->{parent_id}) . ',' 
		. quote_nullable($data->{part})
		. ") RETURNING id";
	$rv = spi_exec_query($q);
	return SKIP unless $rv->{status} eq 'SPI_OK_INSERT_RETURNING' and $rv->{processed} == 1;

	my @jetcols = qw/title part node_path parent_id/; # columns to remove from data table
	delete $data->{$_} for @jetcols;
	$data->{id} = $node_id;
	my $keys = join ',', keys %{$data};
	my $values = join ',', (map {quote_nullable($_)} values %{$data});
	$q = "INSERT INTO data.$base_name ($keys) VALUES ($values)";
	$rv = spi_exec_query($q);
	return SKIP unless $rv->{status} eq 'SPI_OK_INSERT' and $rv->{processed} == 1;

	# This seems to be the syntax to use for setting id. Strange, but it works
	$_TD->{new} = {id => $node_id};
	return MODIFY;
$$
LANGUAGE 'plperl' VOLATILE;

CREATE OR REPLACE FUNCTION get_calculated_node_path(param_id integer) RETURNS text[] AS
$$
	SELECT CASE
		WHEN s.parent_id IS NULL THEN ARRAY[s.part]
		ELSE jet.get_calculated_node_path(s.parent_id) || s.part
	END
	FROM jet.path s
	WHERE s.id = $1;
$$
LANGUAGE sql;

CREATE OR REPLACE FUNCTION trig_update_node_path() RETURNS trigger AS
$$
BEGIN
	IF TG_OP = 'UPDATE' THEN
		IF (COALESCE(OLD.parent_id,0) != COALESCE(NEW.parent_id,0) OR NEW.id != OLD.id OR NEW.part != OLD.part) THEN
			-- update all nodes that are children of this one including this one
			UPDATE path SET node_path = jet.get_calculated_node_path(id)
				WHERE OLD.node_path @> path.node_path;
		END IF;
	ELSIF TG_OP = 'INSERT' THEN
		UPDATE jet.path SET node_path = jet.get_calculated_node_path(NEW.id) WHERE path.id = NEW.id;
	END IF;
  RETURN NEW;
END
$$
LANGUAGE 'plpgsql' VOLATILE;

--
-- Check that a row has the correct parent type
--

CREATE OR REPLACE FUNCTION trig_check_basetype() RETURNS trigger AS
$$
DECLARE
	parent_array int[];
	parent_type int;
BEGIN
	IF new.parent_id IS NULL THEN
		RETURN NEW;
	END IF;
	SELECT parent INTO parent_array FROM jet.nodepath WHERE node_id = NEW.id;
	SELECT basetype_id INTO parent_type FROM jet.nodepath WHERE node_id = NEW.parent_id;
	IF parent_type = ANY (parent_array) THEN
		RETURN NEW;
	ELSE
		RAISE INFO 'Can''t insert child type % under parent %', NEW.parent_id, parent_type;
		RETURN NULL;
	END IF;
END
$$
LANGUAGE 'plpgsql' VOLATILE;

-- Path triggers

-- for postgreSQL 9.0 -- you can use this syntax to save unnecessary check of trigger function
CREATE TRIGGER trig01_check_basetype AFTER INSERT OR UPDATE OF parent_id
	ON path FOR EACH ROW
	EXECUTE PROCEDURE trig_check_basetype();

CREATE TRIGGER trig01_update_node_path AFTER INSERT OR UPDATE OF id, parent_id, part
	ON path FOR EACH ROW
	EXECUTE PROCEDURE trig_update_node_path();

COMMIT;