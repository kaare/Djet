#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More tests => 5;

use_ok 'Jet::Engine::Loader';

# Test
my $dsn = 'dbi:Pg:dbname=album';
my $username = undef;
my $password = undef;
my %connect_options = ();

my $dbh = DBI->connect($dsn, $username, $password, \%connect_options) or die;

ok(my $loader = Jet::Engine::Loader->new(dbh => $dbh), 'New Jet Engine Loader');
ok(my $tables = $loader->load(), 'Load data tables');
use Data::Dumper;
print STDERR Dumper $tables;
print STDERR Dumper $tables->{album}->column('test')->column_size;