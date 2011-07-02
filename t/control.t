#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use_ok('Jet::Control');

ok (my $config = Jet::Control->instance, 'Create 1st instance');
ok (my $test = Jet::Test::Control->new, 'Create test instance');
is_deeply( $config->stash, {a => 1}, 'Stash is set in module');

package Jet::Test::Control;

use Jet::Control;

sub new {
	my $class = shift;
	my $config = Jet::Control->instance;
	$config->stash({a => 1});
};