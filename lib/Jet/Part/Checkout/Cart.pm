package Jet::Part::Checkout::Cart;

use 5.010;
use Moose::Role;

requires qw/
	cart
	checkout
/;

=head1 NAME

Jet::Part::Checkout::Cart

=head1 DESCRIPTION

Displays and updates the cart in the checkout phase

=cut

before 'init_data' => sub {
	my $self = shift;
};

no Moose::Role;

1;

# COPYRIGHT

__END__

