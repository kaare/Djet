package Engine;

use 5.010;
use strict;
use warnings;
use Test::More;

use Jet::Starter;

$ENV{JET_APP_ROOT} = './t';
my $starter = Jet::Starter->new;
my $schema = $starter->schema;
my $config = $schema->config;
ok(my $basetype = $schema->resultset('Jet::Basetype')->first, '1st basetype');

done_testing;
