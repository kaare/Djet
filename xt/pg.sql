\set ECHO
\set QUIET 1
-- Turn off echo and keep things quiet.

-- Format the output for nice TAP.
\pset format unaligned
\pset tuples_only true
\pset pager

-- Revert all changes on failure.
\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true
\set QUIET 1

-- Load the TAP functions.
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

-- Plan the tests.
SELECT plan(3);

-- Run the tests.
PREPARE update_data_node AS UPDATE djet.node SET part='test' WHERE id=4;
SELECT lives_ok('update_data_node', 'Update the path');
SELECT results_eq(
    'SELECT node_path FROM djet.data_node WHERE node_id=4',
    ARRAY[ '/groups/test' ],
    'Node path has changed'
);
SELECT results_eq(
    'SELECT node_path FROM djet.data_node WHERE node_id=5',
    ARRAY[ '/groups/test/kaare' ],
    'Node path has changed for children too'
);
-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;
