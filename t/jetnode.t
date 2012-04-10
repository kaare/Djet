#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use Jet::Context;

use lib 't/lib';
use Test;

my $c = Jet::Context->instance;
my $node_path = '--test--';
is(my $node = $c->nodebox->find_node_path($node_path), undef, 'Find no node');
$node_path = '/groups/rasmussen/kaare';
ok($node = $c->nodebox->find_node_path($node_path), 'Find node');
isa_ok($node, 'HASH', 'Node type');
ok(my $userlogin = $node->get_userlogin, 'Did the role work?');
is($userlogin, 'kaare', '- correctly?');
ok(my $children = $node->children, 'Get children');
isa_ok($children, 'ARRAY', 'Chilren ISA ARRAY');
ok(my $scratch = $children->[0], 'First child');
isa_ok($scratch, 'Jet::Node', 'Node type');
is($scratch->path, '/groups/rasmussen/kaare/scratch', 'Node uri');
is($scratch->basetype->{name}, 'photoalbum', 'Base type');
is($scratch->get_column('title'), 'Scratchpad', 'Node title');
ok(my $photos = $scratch->children, 'Get all children (photos)');
is_deeply($photos, [], 'Empty list');

done_testing();
