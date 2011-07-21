#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use_ok('Jet::Context');

ok (my $context = Jet::Context->instance, 'Create 1st instance');
ok (my $test = Jet::Test::Context->new, 'Create test instance');
is_deeply( $context->stash, {a => 1}, 'Stash is set in module');

package Jet::Test::Context;

use Jet::Context;

sub new {
	my $class = shift;
	my $config = Jet::Context->instance;
	$config->stash->{a} = 1;
};