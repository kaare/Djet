package Djet::Shop::Cart::Product;

use Moose;
use MooseX::NonMoose;

extends 'Interchange6::Cart::Product';

=head1 NAME

Djet::Shop::Cart::Product

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 cart_row

The cart row

=cut

has node_data => (
	is => 'ro',
	isa => 'Djet::Schema::Result::Djet::DataNode',
	lazy_build => 1,
);

sub _build_node_data {
	my $self = shift;
	my $model = $self->cart->model;
	my $cart_product = $model->resultset('Djet::DataNode')->find({node_id => $self->sku});
    return $cart_product;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

