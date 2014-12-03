#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Pod::Coverage;

my @modules=all_modules('lib/Djet.pm', 'lib/Djet');
plan tests=>scalar(@modules);
map { pod_coverage_ok($_) } @modules;

done_testing();
