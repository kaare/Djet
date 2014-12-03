#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use Test::More;

use_ok('Djet::Stuff::QueryBuilder');

my $qb = Djet::Stuff::QueryBuilder->new();

isa_ok($qb, 'Djet::Stuff::QueryBuilder', 'It\'s a QueryBuilder');
my $where = {parent_id => 42};
my $opt = 'node_path';
ok(my ($sql, @binds) = $qb->select(
		"jet.path",
		'*',
		$where,
		$opt
	), 'Simple sql generation');
is($sql, 'SELECT * FROM jet.path WHERE ( parent_id = ? ) ORDER BY node_path', 'Correct SQL');
is_deeply(@binds, 42, 'Correct Bind values');

$where->{base_type} = 'photoalbum';

ok(($sql, @binds) = $qb->select(
		"jet.path",
		'*',
		$where,
		$opt
	), 'Simple sql generation');
is($sql, 'SELECT * FROM jet.path WHERE ( ( base_type = ? AND parent_id = ? ) ) ORDER BY node_path', 'Correct SQL');
is_deeply(\@binds, [ 'photoalbum', 42 ], 'Correct Bind values');

my $current_path = '/long/path/follows/short/stuff/by/way/too/much/';
my @ancestor_paths;
push @ancestor_paths,  $ancestor_paths[$#ancestor_paths] || '' . $_ . '/' for  split '/', $current_path;
pop @ancestor_paths;
$where = {node_path => {'-in' => \@ancestor_paths}};
$opt = 'length(node_path)';
ok(($sql, @binds) = $qb->select(
		"jet.path",
		'*',
		$where,
		$opt
	), 'Find ancestors');
is($sql, 'SELECT * FROM jet.path WHERE ( node_path IN ( ?, ?, ?, ?, ?, ?, ?, ?, ? ) ) ORDER BY length(node_path)', 'Correct SQL');
is_deeply(\@binds, \@ancestor_paths, 'Correct Bind values');

done_testing();
