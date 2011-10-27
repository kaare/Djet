#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use_ok 'Jet::Stuff';

use lib 't/lib';
use Test;

my $db_name = Test::db_name;

# Test
ok(my $stuff = Jet::Stuff->new(dbname => $db_name), 'New Jet Stuff');
isa_ok($stuff, 'Jet::Stuff', 'ISA Jet Stuff');
warn ref $stuff;
ok(my @tables = $stuff->schema->tables(), 'Data tables');
use Data::Dumper;
print STDERR Dumper @tables;
# print STDERR Dumper $tables->{album}->column('albumname');
# print STDERR Dumper $tables->{album}->column('albumname')->column_size, ref $tables->{album}->column('test');

done_testing();
