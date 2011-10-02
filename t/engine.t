#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use_ok('Jet::Stuff');

my $dbh;

my %ci = (
	dbname => 'album',
	username => 'kaare',
	password => undef,
	connect_options => {
		AutoCommit => 1,
		quote_char => '"',
		RaiseError => 1,
		pg_enable_utf8 => 1,
	},
);

ok(my $stuff = Jet::Stuff->new(%ci), 'Start your stuffs!');
isa_ok($stuff, 'Jet::Stuff', 'It\'s a Plane, it\'s a bird. No...');

ok(my $rows = $stuff->search('domain', {id => 1}), 'Search domain');
use Data::Dumper;
warn Dumper $rows;
ok(my $result = $stuff->result($rows), 'Result');
warn Dumper $result->rows;

my $row = $result->next;
my $id = $row->get_column('id');
warn Dumper $id, $row->get_columns, $row->num_columns;

done_testing();
