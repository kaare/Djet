#! /usr/bin/env perl -w

use 5.010;
use strict;
use warnings;

use File::Find ();

use Djet::Schema;

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;
sub preprocess;

my $dsn = 'dbi:Pg:dbname=__djet_test__';
my $schema  = Djet::Schema->connect($dsn) or die;


File::Find::find({wanted => \&wanted, preprocess => \&preprocess}, '/');
exit;

sub wanted {
#    insert into an array
#    my @path = split '/', $name;
#    my $bind = [\@path];
#    insert as string
#    my $bind = [$name];
#    insert as ltree

	my $lname = $_;
	return if $lname =~ /\./;

	$lname =~ s/\W/_/g;
	my $ldir = $dir;
	$ldir =~ s/^\///;
	$ldir =~ s/\//./g;
	$ldir =~ s/[-@]/_/g;
	my $parent = $schema->resultset('Djet::DataNode')->find({node_path => $ldir, basetype_id => 2});
	my $node = $schema->resultset('Djet::DataNode')->create({
		basetype_id => 3,
		parent_id => $parent ? $parent->node_id : undef,
		part => $lname,
	}) unless $schema->resultset('Djet::DataNode')->find({node_path => $lname, basetype_id => 3});

}

sub preprocess {
	my @list = @_;
	my $lname = $_;
	$lname =~ s|^[/\.]||;
	$lname =~ s/\W/_/g;
warn $lname;
	my $ldir = $dir;
	$ldir =~ s|(.*)/\w+$|$1|;
	$ldir =~ s/^\///;
	$ldir =~ s/\//./g;
	$ldir =~ s/[-@]/_/g;
	my $parent = $schema->resultset('Djet::DataNode')->find({node_path => $ldir, basetype_id => 2});
	my $node = $schema->resultset('Djet::DataNode')->create({
		basetype_id => 2,
		parent_id => $parent ? $parent->node_id : undef,
		part => $lname,
	});
	return @list;
}
