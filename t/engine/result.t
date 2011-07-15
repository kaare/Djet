#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More tests => 6;

use_ok 'Jet::Engine::Iterator';
use Data::Dumper;

# Test
my $dsn = 'dbi:Pg:dbname=album';
my $username = undef;
my $password = undef;
my %connect_options = ();

my $dbh = DBI->connect($dsn, $username, $password, \%connect_options) or die;

my $q = 'SELECT * FROM data.domain_view';
my $sth = $dbh->prepare($q);
$sth->execute(@{ []});
ok(my $iterator = Jet::Engine::Iterator->new(sth => $sth, raw => 1), 'Raw Jet Engine Iterator');
ok(my $next = $iterator->next(), 'Get next row');
print STDERR Dumper $next;
ok(my $data = $iterator->all(), 'Get all data');
print STDERR Dumper $data;
$sth->execute(@{ []});
ok($iterator = Jet::Engine::Iterator->new(sth => $sth), 'Cooked Jet Engine Iterator');
ok($data = $iterator->all(), 'Get all data');
print STDERR Dumper $data;
