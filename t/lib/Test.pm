package Test;

use 5.010;
use strict;
use warnings;
	
use Test::More;

use Jet::Stuff;

sub db_name {
	return '__jet_test__';
}

sub schema {
	my $db_name = db_name;
	ok( my $dbh = DBI->connect(qq{dbi:Pg:dbname=$db_name}), 'Connect to test database');
	ok(my $schema = Jet::Stuff->new(dbh => $dbh), 'New schema');
	return $schema;
}

1;