#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use lib 't/lib';
use Test;

use_ok 'Jet::Stuff::Loader';

my $db_name = Test::db_name;
my $dsn = 'dbi:Pg:dbname=' . $db_name;
my $username = undef;
my $password = undef;
my %connect_options = ();

my %tables = (
    tables  => [qw/domain person photo photoalbum usergroup/],
    columns => [2, 5, 4, 2, 2],
    fks     => [(0) x 5],
    pks     => [('id') x 5],
);
my $dbh = DBI->connect($dsn, $username, $password, \%connect_options) or die;

ok(my $loader = Jet::Stuff::Loader->new(dbh => $dbh), 'New Jet Stuff Loader');
ok(my $schema = $loader->schema(), 'Get data schema');
isa_ok($schema, 'DBIx::Inspector::Driver::Pg', 'Schema is DBIx::Inspector::Driver::Pg');
ok($schema->tables, 'We have tables');
ok($schema->table($_), "Table $_ exists") for @{$tables{tables}};
is($schema->table($_)->columns->all, shift @{$tables{columns}}, "Table $_ columns") for @{$tables{tables}};
is($schema->table($_)->fk_foreign_keys->all, shift @{$tables{fks}}, "Table $_ foreign keys") for @{$tables{tables}};
is($schema->table($_)->primary_key->next->name, shift @{$tables{pks}}, "Table $_ primary keys") for @{$tables{tables}};

done_testing();
 