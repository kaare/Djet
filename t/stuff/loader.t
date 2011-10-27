#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use_ok 'Jet::Stuff::Loader';

# Test
use lib 't/lib';
use Test;

my $db_name = Test::db_name;
my $dsn = 'dbi:Pg:dbname=' . $db_name;
my $username = undef;
my $password = undef;
my %connect_options = ();

my $dbh = DBI->connect($dsn, $username, $password, \%connect_options) or die;

ok(my $loader = Jet::Stuff::Loader->new(dbh => $dbh), 'New Jet Stuff Loader');
ok(my $schema = $loader->schema(), 'Get data schema');
isa_ok($schema, 'DBIx::Inspector::Driver::Pg', 'Schema is DBIx::Inspector::Driver::Pg');
use Data::Dumper;
print STDERR Dumper $schema->tables;
print STDERR Dumper $schema->table('photoalbum');
print STDERR Dumper $schema->table('photoalbum')->columns;
print STDERR Dumper $schema->table('photoalbum')->fk_foreign_keys;
print STDERR Dumper $schema->table('photoalbum')->pk_foreign_keys;
# print STDERR Dumper $tables;
# print STDERR Dumper $tables->{album}->column('sth')->column_size;

done_testing();
 