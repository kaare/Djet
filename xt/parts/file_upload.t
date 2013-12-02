#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib 't/lib';

use_ok('Jet::Engine::Part::File::Upload');
ok(my $part = Jet::Engine::Part::File::Upload->new(), 'New part');
is($part->title, 'File Upload', 'Correct Title');
is_deeply($part->parameter_names, [qw/parent_id/], 'Parameter Names');

done_testing();