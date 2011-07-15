#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use_ok('Jet::Engine');

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

ok(my $engine = Jet::Engine->new(%ci), 'Start your engines!');
isa_ok($engine, 'Jet::Engine', 'It\'s a Plane, it\'s a bird. No...');

ok(my $result = $engine->search('domain', {id => 1}), 'Search domain');
my $row = $result->next;
my $id = $row->get_column('id');
use Data::Dumper;
warn Dumper $id, $row->get_columns;
;

done_testing();
