#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use lib 't/lib';
use Test;

use_ok('Djet::Stuff');

my $stuff = Test::schema;

ok(my $data = $stuff->insert({basetype_id=>6,parent_id=>6,title=>'Family Photo',columns=>'{"test"}'},{returning => '*'}), 'Insert node');
isa_ok($stuff, 'Djet::Stuff', 'It\'s a Plane, it\'s a bird. No...');
ok(my $rows = $stuff->ft_search_node('test a rossa'), 'Fulltext search');
is(@$rows, 1, 'Number of rows');
is($rows->[0]->{title}, 'Family Photo', 'The row title');
ok(my $row = $rows->[0], 'Get 1st row as an object');
is($row->{title}, 'Family Photo', 'The row title');
is($row->{id}, $data->{id}, 'Row id');
ok(my %columns = %$row, 'Get columns');
is(keys %columns, 11, 'Number of columns');
ok($stuff->delete({id => $data->{id}}), 'Remove dnode');

done_testing();
