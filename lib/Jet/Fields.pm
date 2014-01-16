package Jet::Fields;

use 5.010;
use Moose;
use namespace::autoclean;

use JSON;

use Jet::Field;

with 'Jet::Role::Log';

=head1 NAME

Jet::Fields - Jet Fields Base Class

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 datacolumns

The raw data columns

=cut

has datacolumns => (
	isa => 'HashRef',
	is => 'ro',
);

=head2 fields

Returns an arrayref with all the fields

=cut

has fields => (
	is => 'ro',
	isa	 => 'ArrayRef[Jet::Field]',
	default => sub {
		my $self = shift;
		return [ map { $self->$_  } @{ $self->fieldnames } ];
	},
	lazy => 1,
);

=head1 METHODS

=head2 fields_as_json

Return the fields (type, title, value) as JSON

=cut

sub fields_as_json {
	my $self = shift;
	return [ map { $_->as_json } @{ $self->fields } ];
}

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__
