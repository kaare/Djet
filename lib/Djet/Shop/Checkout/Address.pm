package Jet::Shop::Checkout::Address;

use 5.010;
use Moose;

extends 'Jet::Shop::Checkout';

=head1 NAME

Jet::Shop::Checkout::Address

=head2 DESCRIPTION

Handles the address in the checkout process

=cut

sub has_all_data {
	my $self = shift;
	my $checkout = $self->checkout;
	my $params = $self->request->body_parameters->as_hashref;
	my $step_name = $self->step->name;
	$checkout->{data}{$step_name} = $params;
	return 1;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
