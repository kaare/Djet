#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

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
$domain->add($args); #! 
print STDERR Dumper $domain->data;
$args = {
	title => 'album',
	part => 'album1',
	basetype => 'album',
	albumname => 'album',
};
ok (my $album = $domain->add_child($args), 'Add a child');

$schema->txn_rollback;
