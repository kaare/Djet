#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use_ok 'Jet::Stuff';

# Test
my $dbname = 'album';
my $username = undef;
my $password = undef;
my %connect_options = ();

#ok(my $stuff = Jet::Stuff->new(dbname => $dbname, username => $username, password => $password, connect_options => \%connect_options), 'New Jet Stuff');
ok(my $stuff = Jet::Stuff->new(dbname => $dbname), 'New Jet Stuff');
isa_ok($stuff, 'Jet::Stuff', 'ISA Jet Stuff');
warn ref $stuff;
ok(my @tables = $stuff->schema->tables(), 'Data tables');
use Data::Dumper;
print STDERR Dumper @tables;
# print STDERR Dumper $tables->{album}->column('albumname');
# print STDERR Dumper $tables->{album}->column('albumname')->column_size, ref $tables->{album}->column('test');

done_testing();
