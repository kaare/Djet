package Djet::Trait::Field::Email;

use Moose::Role;

use Data::FormValidator::Constraints qw(:closures);

=head1 NAME

Djet::Trait::Field::Email - decorate the email field

=cut

=head1 METHODS

=head2 constraint_methods

=cut

sub constraint_methods {
	my $self = shift;
	return $self->name => email();
}

1;
