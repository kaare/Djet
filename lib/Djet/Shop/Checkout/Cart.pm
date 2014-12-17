package Djet::Shop::Checkout::Cart;

use 5.010;
use Moose;

extends 'Djet::Shop::Checkout';

=head1 NAME

Djet::Shop::Checkout::Cart

=head2 DESCRIPTION

Handles the cart in the checkout process

=head2 has_all_data

Returns 1 if all the necessary data is entered correctly

=cut

sub has_all_data {
	my $self = shift;
	my $stash = $self->stash;
	my $params = $self->request->body_parameters;
	my %items = map {
		my $param = $_;
		my ($identifier, $sku) = split/_/, $param;
		$sku => $params->{$param};
	} grep {/^qty_/} keys %$params;
	my $cart = $self->stash->{local}->cart;
	$cart->update(%items);

	return if $params->{update}; # Just update the cart
	return 1;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
