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
ok(my $datanode = $schema->resultset('Jet::DataNode')->find({node_path => '/jet/config/basetype'}), 'basetype datanode');
use Data::Dumper;
warn ref $datanode->datacolumns;
warn $datanode->text;
warn $datanode->parent;

done_testing;
