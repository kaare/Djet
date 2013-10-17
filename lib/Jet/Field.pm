package Jet::Field;

use 5.010;
use Moose;
use namespace::autoclean;

with 'MooseX::Traits';

=head1 NAME

Jet::Field - Attributes and feature for Jet Fields

=head1 ATTRIBUTES

=head2 title

The field's title

=cut

has title => (
	is => 'ro',
	isa => 'Str',
);

=head2 value

The field's value

=cut

has value => (
	is => 'ro',
);

=head2 node

The node that contains this attribute

=cut

has node => (
	is => 'ro',
	isa => 'Jet::Node',
);

no Moose::Role;

1;

# COPYRIGHT

__END__
