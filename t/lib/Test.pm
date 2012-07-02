package Test;

use 5.010;
use strict;
use warnings;
	
use Test::More;

#use Jet::Context;
#use Jet::Stuff;

sub db_name {
	return '__jet_test__';
}

sub schema {
	my $db_name = db_name;
	ok( my $dbh = DBI->connect(qq{dbi:Pg:dbname=$db_name}), 'Connect to test database');
	ok($dbh->{pg_server_version} >= 90100, 'Server at least PostgreSQL 9.1');
	ok(my $schema = Jet::Stuff->new(dbh => $dbh), 'New schema');
	my $context = Jet::Context->new(schema => $schema);
	return $schema;
}

#my $c = Jet::Context->instance;
#$c->schema(schema());

1;
