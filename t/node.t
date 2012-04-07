#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib 't/lib';

use Test;

my $schema = Test::schema;

use_ok('Jet::Node'); # Has to be AFTER context is set in Test

ok($schema->txn_begin, 'Begin transaction');

my $args = {
	title => 'domain',
	part => '',
	name => 'domain',
};

ok(my $nodedata = $schema->find_node({ node_path => '' }), 'Get nodedata for domain');
ok(my $domain = Jet::Node->new(row => $nodedata), 'Nodify data');
ok(my $row = $domain->row, 'Get node row');
is($row->row_data->{basetype_id}, 1, 'Basetype');
$args = {
	title => 'New usergroup',
	part => 'newusergroup',
	basetype => 'usergroup',
	name => 'newusergroup',
};
ok(my $grp = $domain->add_child($args), 'Add a child');
ok($row = $grp->row, 'Get node row');
is($row->row_data->{basetype_id}, 3, 'New table name');
ok(my $children = $domain->children(), 'All children');
is(@$children, 2, 'Number of children');
ok($children = $domain->children(basetype => 'directory'), 'All directory children');
is(@$children, 1, 'Number of directory children');
ok($children = $domain->children(basetype => 'xyzzy'), 'All xyzzy children');
is(@$children, 0, 'Number of xyzzy children (none)');

$schema->txn_rollback;

done_testing();