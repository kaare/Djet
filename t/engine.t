#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More tests => 3;

use_ok('Jet::Engine');

my $dbh;

my %ci = (
	dbname => 'jet_test',
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