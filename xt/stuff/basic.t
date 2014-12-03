#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use_ok 'Djet::Stuff';

use lib 't/lib';
use Test;

my $db_name = Test::db_name;

my %tables = (
    tables  => [qw/domain person photo photoalbum usergroup/],
    columns => [1, 1, 4, 3, 1, 1],
    fks     => [(0) x 6],
    pks     => [('id') x 6],
);

# Test
ok(my $stuff = Djet::Stuff->new(dbname => $db_name), 'New Djet Stuff');
isa_ok($stuff, 'Djet::Stuff', 'ISA Djet Stuff');
ok(my @tables = $stuff->schema->tables(), 'Data tables');
is(@tables, 6, 'Correct number of tables');
is($_->columns->all, shift @{$tables{columns}}, 'Table ' .$_->name . ' columns') for @tables;
is($_->fk_foreign_keys->all, shift @{$tables{fks}}, 'Table ' .$_->name . ' foreign keys') for @tables;
is($_->primary_key->next->name, shift @{$tables{pks}}, 'Table ' .$_->name . ' primary keys') for @tables;

done_testing();
