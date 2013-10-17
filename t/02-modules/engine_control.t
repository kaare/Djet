use 5.010;
use strict;
use warnings;
use Test::More;

use_ok('Jet::Engine::Control', 'Load module');

ok(my $control = Jet::Engine::Control->new, 'New control');

my @phases = qw/init data render/;

ok($control->omit->$_("$_ step"), "Omit a step ($_)") for @phases;
do {my $method = "_$_"; is_deeply($control->omit->$method, ["$_ step"], "Omit $_ was correct") } for @phases;

ok($control->skip("$_"), "Skip the rest of $_") for @phases;
is_deeply($control->_skip, [@phases], 'Skip was correct');

is($control->clear_skip, undef, 'Clear Skip');
do {my $method = "clear_$_"; is($control->omit->$method, undef, "Clear $_") } for @phases;

ok($control->omit->$_(1..4), "Omit some steps ($_)") for @phases;
do {my $method = "_$_"; is_deeply($control->omit->$method, [1..4], "Omit $_ was correct") } for @phases;

done_testing;
