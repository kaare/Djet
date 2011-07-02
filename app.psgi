use strict;
use warnings;

use Jet;

my $machine = Jet->new;
my $app = sub { $machine->run_psgi(@_) };