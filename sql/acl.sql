-- Test bed

SELECT d.*, a.acl
FROM jet.data_node d
LEFT JOIN (
	SELECT d.node_id, array_agg(array_to_string(p.columns, ',')) acl
	FROM jet.data_node d
	JOIN jet.node_tree n ON d.node_id=n.child
	JOIN jet.data_node p ON n.parent=p.node_id
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
	SELECT d.node_id, array_agg(array_to_string(p.columns, ',')) acl
	FROM datanode d
	JOIN jet.node_tree n ON d.node_id=n.child
	JOIN jet.data_node p ON n.parent=p.node_id
	JOIN jet.basetype b ON p.basetype_id=b.id
	AND b.name='acl'
	GROUP BY d.node_id
) a USING (node_id)
