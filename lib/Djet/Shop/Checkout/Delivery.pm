package Djet::Shop::Checkout::Delivery;

use 5.010;
use Moose;

extends 'Djet::Shop::Checkout';

=head1 NAME

Djet::Shop::Checkout::Delivery

=head2 DESCRIPTION

Handles the delivery steop of the checkout process

=head2 has_all_data

Returns 1 if all the necessary data is entered correctly

=cut

sub has_all_data {
	my $self = shift;
	my $checkout = $self->checkout;
	my $params = $self->model->request->body_parameters->as_hashref;
	my $step_name = $self->step->name;
	$checkout->{data}{$step_name} = $params;
	return 1;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
