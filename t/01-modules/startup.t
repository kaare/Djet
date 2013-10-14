#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Test::More;

use_ok 'Jet::Starter';

use lib 't/lib';
use Test;

$ENV{JET_APP_ROOT} = './t';
ok(my $startup = Jet::Starter->new, 'New Jet Starter');
isa_ok($startup, 'Jet::Starter', 'ISA Jet Starter');
ok(my $config = $startup->config, 'Init config');
isa_ok($config, 'Jet::Config', 'ISA Jet Config');
use Data::Dumper;
warn Dumper $config;
ok(my $schema = $startup->schema, 'Init Schema');
isa_ok($schema, 'Jet::Schema', 'ISA Jet Schema');

done_testing();
