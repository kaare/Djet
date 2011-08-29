#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use Jet::Context;
use Data::Dumper;
use_ok('Jet::Node');

my $c = Jet::Context->instance();
my $schema = $c->schema;

my $node_path = ['','groups','rasmussen','kaare'];
my $nodedata = $schema->find_node({ node_path =>  $node_path });
my $node = Jet::Node->new(
	row => $nodedata,
) if $nodedata;
my $children = $node->children;
my $scratch = $children->[0];
say ref $scratch, Dumper $scratch, $scratch->uri;
my $photos = $scratch->children;
for my $photo (@$photos) {
	say 'photo->'.$photo->row->get_column('title');
}

say $scratch->row->get_column('title');
# my $parents = $node->parents(base_type => 'usergroup');
# say Dumper $parents;

done_testing();