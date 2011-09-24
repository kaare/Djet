package Jet::Role::Person::Login;

use 5.010;
use Moose::Role;

=head1 NAME

Jet::Role::Person::Login - Role for logging in to Jet

=head1 SYNOPSIS


with 'Jet::Role::Person::Login';

=head1 ATTRIBUTES

=head1 METHODS

=head2 login

Checks the person data table and returns true if there is a match

=cut

# XXX Role

sub login {
	my ($self, $login, $pwd) = @_;
	my $c = Jet::Context->instance;
	my $schema = $c->schema;
	my $person = $schema->search('person', { userlogin =>  $login, password => $pwd  });
	return unless $person;
	return $person->[0];
}

1;
