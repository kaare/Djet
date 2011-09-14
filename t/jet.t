#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use DBI;
 
use Test::Class::Load 't/lib';

our $dbh;

my $ok = startup(); 
Test::Class->runtests() if $ok;

sub db_name {'__jet::test__'};

sub startup {
	my $command = 'dropdb '.db_name;
	qx{$command};
	$command = 'createdb -e '.db_name;
	qx{$command} || return;

	$command = 'psql '.db_name.'<sql/jet.sql';
	qx{$command} or return;

	$dbh = DBI->connect('dbi:Pg:dbname='.db_name) or return;
};
