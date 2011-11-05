#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use Jet::Stuff;

use lib 't/lib';
use Test;

my $schema = Test::schema;

use_ok('Jet::Node'); # Has to be AFTER context is set

my $node_path = '/groups/rasmussen/kaare/';
ok(my $nodedata = $schema->find_node({ node_path =>  $node_path }), 'Find node');
ok(my $node = Jet::Node->new(row => $nodedata), 'Nodify data');
ok(my $children = $node->children, 'Get children');
ok(my $scratch = $children->[0], 'First child');
isa_ok($scratch, 'Jet::Node', 'Node type');
is($scratch->path, '/groups/rasmussen/kaare/scratch/', 'Node uri');
is($scratch->basetype, 'photoalbum', 'Base type');
is($scratch->row->get_column('title'), 'Scratchpad', 'Node title');
ok(my $photos = $scratch->children, 'Get all children (photos)');
is_deeply($photos, [], 'Empty list');

done_testing();