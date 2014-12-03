#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use_ok 'Djet::Starter';

use lib 't/lib';
use Test;

$ENV{JET_APP_ROOT} = './t';
ok(my $startup = Djet::Starter->new, 'New Jet Starter');
isa_ok($startup, 'Djet::Starter', 'ISA Jet Starter');
ok(my $config = $startup->config, 'Init config');
isa_ok($config, 'Djet::Config', 'ISA Jet Config');
ok(my $schema = $startup->schema, 'Init Schema');
isa_ok($schema, 'Djet::Schema', 'ISA Jet Schema');

done_testing();
