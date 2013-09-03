-- Test bed

SELECT d.*, a.acl
FROM jet.data_node d
LEFT JOIN (
	SELECT d.node_id, array_agg(array_to_string(p.datacolumns, ',')) acl
	FROM jet.data_node d
	JOIN jet.data_node p ON n.parent=p.id
	JOIN jet.basetype b ON p.basetype_id=b.id
	WHERE d.node_path=''
	AND b.name='acl'
	GROUP BY d.node_id
) a USING (node_id)
WHERE d.node_path=''
;

WITH datanode AS (
  SELECT *
FROM jet.data_node
WHERE node_path=''
)
SELECT d.*, a.acl
FROM datanode d
LEFT JOIN (
	SELECT d.node_id, array_agg(array_to_string(p.datacolumns, ',')) acl
	FROM datanode d
	JOIN jet.data_node p ON n.parent=p.id
	JOIN jet.basetype b ON p.basetype_id=b.id
	AND b.name='acl'
	GROUP BY d.node_id
) a USING (node_id)

--
-- Find a complete branch in the nodetree
--

CREATE OR REPLACE VIEW data_node_acl AS (
	SELECT d.*, a.acl
	FROM data_node d
	LEFT JOIN (
		SELECT d.node_id, array_agg(array_to_string(p.datacolumns, ',')) acl
		FROM data_node d
		JOIN jet.node_tree n ON d.node_id=n.child
		JOIN jet.data_node p ON n.parent=p.node_id
		JOIN jet.basetype b ON p.basetype_id=b.id
		AND b.name='acl'
		GROUP BY d.node_id
	) a USING (node_id)
);

CREATE OR REPLACE FUNCTION find_nodebranch(path text) RETURNS SETOF data_node_acl
	LANGUAGE plpgsql
	AS $$
DECLARE
	parts text[];
	item text;
	build_part text;
	paths text[];
BEGIN
	parts := regexp_split_to_array(path, E'\/+');
	FOREACH item IN ARRAY parts LOOP
		paths := array_append(paths, array_to_string(ARRAY[paths[array_length(paths, 1)], item], '/'));
	END LOOP;
	RETURN QUERY SELECT *
		FROM jet.data_node_acl
		WHERE node_path = ANY (paths)
		ORDER BY length(node_path) DESC;
END;
$$;
