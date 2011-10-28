#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use lib 't/lib';
use Test;

use_ok 'Jet::Stuff::Result';

my $schema = Test::schema;

my $q = 'SELECT * FROM data.domain_view';
ok(my $rows = $schema->search('domain', {id => 1}), 'Search domain');
ok(my $result = Jet::Stuff::Result->new(rows => $rows, raw => 1, schema => $schema->schema), 'Raw Jet Stuff Result');
my $expected = {
          'domainname' => 'family_photo',
          'id' => 1,
          'node_path' => [
                           ''
                         ],
          'title' => 'Family Photo',
          'parent_id' => undef
        };
ok(my $data = $result->all(), 'Get all data');
is_deeply($data, [$expected], 'All result as expected');
ok($data = $result->next(), 'Get next row');
is_deeply($data, $expected, 'Next result as expected');
ok(!($data = $result->next()), 'Get next row');

done_testing();
