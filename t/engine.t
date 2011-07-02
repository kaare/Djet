#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More tests => 3;

use Jet::Node;
use Plack::Request;

use_ok('Jet::Engine');

my $node = Jet::Node->new;
my $env = {a => 1};
my $req = Plack::Request->new($env);
ok(my $engine = Jet::Engine->new(request => $req, node => $node), 'Start your engines!');
ok($engine->go, 'Lift off!');
