-- Jet development functions
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
	SELECT parent INTO parent_array FROM jet.basetype WHERE id = NEW.basetype_id;
	IF parent_array IS NULL THEN
		RETURN NEW;
	END IF;
	SELECT basetype_id INTO parent_type FROM jet.node WHERE id = NEW.parent_id;
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
CREATE TRIGGER
	trig01_check_basetype
AFTER INSERT OR UPDATE OF
	parent_id
ON
	node
FOR EACH ROW EXECUTE PROCEDURE
	trig_check_basetype();
