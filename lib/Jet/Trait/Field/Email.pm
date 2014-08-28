package Jet::Trait::Field::Email;

use Moose::Role;

use Data::FormValidator::Constraints qw(:closures);

=head1 NAME

Jet::Trait::Field::Email - decorate the email field

=cut

requires qw/value/;

=head1 METHODS

=head2 validation_constraints

=cut

sub constraint_methods {
	my $self = shift;
	return $self->name => email();
}

1;
