#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use_ok 'Jet::Config';

use lib 't/lib';

ok(my $config = Jet::Config->new(app_root => './t'), 'New Jet Config');
isa_ok($config, 'Jet::Config', 'ISA Jet Config');
use Data::Dumper;
warn Dumper $config;

done_testing();
