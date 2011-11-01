#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use lib 't/lib';
use Test;

use_ok('Jet::Stuff');

my $stuff = Test::schema;

isa_ok($stuff, 'Jet::Stuff', 'It\'s a Plane, it\'s a bird. No...');
ok(my $rows = $stuff->search('domain', {id => 1}), 'Search domain');
is(@$rows, 1, 'Number of rows');
is($rows->[0]->{title}, 'Family Photo', 'The row title');
ok(my $row = $stuff->row($rows->[0], 'domain'), 'Get 1st row as an object');
is($row->get_column('title'), 'Family Photo', 'The row title');
is($row->get_column('id'), 1, 'Row id');
ok($row->get_columns, 'Get columns');
is($row->num_columns, 5, 'Number of columns');

done_testing();
