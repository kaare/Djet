#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use_ok 'Djet::Starter';

use lib 't/lib';
use Test;

$ENV{JET_APP_ROOT} = './t';
ok(my $startup = Djet::Starter->new, 'New Djet Starter');
isa_ok($startup, 'Djet::Starter', 'ISA Djet Starter');
ok(my $config = $startup->config, 'Init config');
isa_ok($config, 'Djet::Config', 'ISA Djet Config');
ok(my $model = $startup->model, 'Init model');
isa_ok($model, 'Djet::model', 'ISA Djet model');

done_testing();
