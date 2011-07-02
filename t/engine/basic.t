#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More tests => 5;

use_ok 'Jet::Engine';

# Test
my $dbname = 'album';
my $username = undef;
my $password = undef;
my %connect_options = ();

#ok(my $engine = Jet::Engine->new(dbname => $dbname, username => $username, password => $password, connect_options => \%connect_options), 'New Jet Engine');
ok(my $engine = Jet::Engine->new(dbname => $dbname), 'New Jet Engine');
ok(my $tables = $engine->data_tables(), 'Data tables');
use Data::Dumper;
print STDERR Dumper $tables;
print STDERR Dumper $tables->{album}->column('albumname');
print STDERR Dumper $tables->{album}->column('albumname')->column_size, ref $tables->{album}->column('test');