package Jet::Stuff::Loader;

use Moose;
use DBIx::Inspector;
use Carp ();

has 'dbh'       => (isa => 'DBI::db', is => 'ro');
has 'schema'       => (
	isa => 'DBIx::Inspector::Driver::Pg',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return DBIx::Inspector->new(dbh => $self->dbh, schema => 'data');
	}
);

__PACKAGE__->meta->make_immutable;