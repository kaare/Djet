#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More tests => 6;

use Jet::Engine::Loader;

use_ok 'Jet::Engine::Result';
use Data::Dumper;

# Test
my $dsn = 'dbi:Pg:dbname=album';
my $username = undef;
my $password = undef;
my %connect_options = ();

my $dbh = DBI->connect($dsn, $username, $password, \%connect_options) or die;

my $loader = Jet::Engine::Loader->new(dbh => $dbh);
my $schema = $loader->schema();

my $q = 'SELECT * FROM data.domain_view';
my $sth = $dbh->prepare($q);
$sth->execute(@{ []});
my $rows = $sth->fetchall_arrayref({});
ok(my $result = Jet::Engine::Result->new(rows => $rows, raw => 1, schema => $schema), 'Raw Jet Engine Result');
ok(my $next = $result->next(), 'Get next row');
print STDERR Dumper $next;
ok(my $data = $result->all(), 'Get all data');
print STDERR Dumper $data;
$sth->execute(@{ []});
ok($result = Jet::Engine::Result->new(sth => $sth, raw => 0, schema => $schema, table_name => 'album'), 'Cooked Jet Engine Result');
ok($data = $result->all(), 'Get all data');
print STDERR Dumper $data;
