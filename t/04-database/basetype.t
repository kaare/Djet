package Engine;

use 5.010;
use strict;
use warnings;
use Test::More;

use Djet::Starter;

$ENV{JET_APP_ROOT} = './t';
my $starter = Djet::Starter->new;
my $model = $starter->model;
my $config = $model->config;
ok(my $basetype = $model->resultset('Djet::Basetype')->first, '1st basetype');

done_testing;
