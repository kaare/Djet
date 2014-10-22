package Jet::Shop::Checkout::Cart;

use 5.010;
use Moose;

extends 'Jet::Shop::Checkout';

=head1 NAME

Jet::Shop::Checkout::Cart

=head2 DESCRIPTION

Handles the cart in the checkout process

=cut

sub has_all_data {
	my $self = shift;
	my $stash = $self->stash;
	my $params = $self->request->body_parameters;
	my %items = map {
		my $param = $_;
		my ($identifier, $sku) = split/_/, $param;
		$sku => $params->{$param};
	} keys %$params;
	my $cart = $self->stash->{local}->cart;
	$cart->update(%items);
	return 1;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
