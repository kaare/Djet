#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Jet::Context;
use Data::Dumper;
use_ok('Jet::Node');

my $c = Jet::Context->instance();
my $schema = $c->schema;

$schema->txn_begin;

my $args = {
	title => 'domain',
	part => '',
	domainname => 'domain',
};
ok (my $domain = Jet::Node->new(basetype => 'domain'), 'Create domain node');
$domain->add($args);
print STDERR "domain: ",Dumper $domain->row;
$args = {
	title => 'album',
	part => 'album',
	basetype => 'album',
	albumname => 'album',
};
ok (my $album = $domain->add_child($args), 'Add a child');
print STDERR "album: ", Dumper $domain->row, $album->row;
ok (my $children = $domain->children(), 'All children');
print STDERR Dumper $children;
ok ($children = $domain->children('album'), 'All album children');
print STDERR Dumper $children->rows;
ok ($children = $domain->children('xyzzy'), 'All xyzzy children (none)');
print STDERR Dumper $children;

$schema->txn_rollback;

done_testing();