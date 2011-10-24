#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Data::Dumper;
use_ok('Jet::Node');

use lib 't/lib';
use Test;

my $schema = Test::schema;

$schema->txn_begin;

my $args = {
	title => 'domain',
	part => '',
	domainname => 'domain',
};

my $nodedata = $schema->find_node({ node_path => [''] });
ok (my $domain = Jet::Node->new(row => $nodedata,), 'Get domain node');
print STDERR "domain: ",Dumper $domain->row;
$args = {
	title => 'album',
	part => 'album',
	basetype => 'photoalbum',
	albumname => 'album',
};
# ok (my $album = $domain->add_child($args), 'Add a child');
# print STDERR "album: ", Dumper $domain->row, $album->row;
ok (my $children = $domain->children(), 'All children');
print STDERR Dumper $children;
ok ($children = $domain->children(base_type => 'directory'), 'All directory children');
print STDERR Dumper $children;
print STDERR ref $children;
ok ($children = $domain->children(base_type => 'xyzzy'), 'All xyzzy children (none)');
print STDERR Dumper $children;

$schema->txn_rollback;

done_testing();