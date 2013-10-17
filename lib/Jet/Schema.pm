use utf8;
package Jet::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-03 11:41:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z/TKrREPcrSUpNIvqFMf9g

=head1 NAME

Jet::Schema

=head1 DESCRIPTION

The Jet database Schema

=head1 ATTRIBUTES

=head2 config

Jet configuration. Jet::Schema wants to know its surroundings upon start.

=cut

has config => (
	is => 'rw',
	isa => 'Jet::Config',
	handles => [qw/
		renderers
		log
	/],
);

=head2 basetypes

Jet Basetypes

=cut

has basetypes => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		return { map { $_->id =>  $_} $self->resultset('Basetype')->search };
	},
	lazy => 1,
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;

# COPYRIGHT

__END__
