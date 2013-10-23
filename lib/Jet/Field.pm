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

no Moose::Role;

1;

# COPYRIGHT

__END__
