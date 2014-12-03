package Engine;

use 5.010;
use strict;
use warnings;
use Test::More;

use Djet::Starter;

$ENV{JET_APP_ROOT} = './t';
my $starter = Djet::Starter->new;
my $schema = $starter->schema;
my $config = $schema->config;
ok(my $basetype = $schema->resultset('Djet::Basetype')->first, '1st basetype');

done_testing;
