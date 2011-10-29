package Jet::Stuff::Loader;

use Moose;
use DBIx::Inspector;

=head1 NAME

Jet::Stuff::Loader - Jet database loader

=head1 DESCRIPTION

Lightweight loading of all the tables

=head1 ATTRIBUTES

=head2 dbh

The database handle

=head2 schema

The database schema

=cut

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

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
