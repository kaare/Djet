#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use_ok 'Jet::Stuff::Result';
use Data::Dumper;

# Test
use lib 't/lib';
use Test;

my $schema = Test::schema;

my $q = 'SELECT * FROM data.domain_view';
ok(my $rows = $schema->search('domain', {id => 1}), 'Search domain');
ok(my $result = Jet::Stuff::Result->new(rows => $rows, raw => 1, schema => $schema), 'Raw Jet Stuff Result');
ok(my $next = $result->next(), 'Get next row');
print STDERR Dumper $next;
ok(my $data = $result->all(), 'Get all data');
print STDERR Dumper $data;

done_testing();
