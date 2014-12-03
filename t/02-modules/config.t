#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use_ok 'Djet::Config';

use lib 't/lib';

ok(my $config = Djet::Config->new(app_root => './t'), 'New Djet Config');
isa_ok($config, 'Djet::Config', 'ISA Djet Config');

done_testing();
