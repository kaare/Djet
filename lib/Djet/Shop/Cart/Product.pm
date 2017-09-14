package Djet::Shop::Cart::Product;

use Moose;
use MooseX::NonMoose;

extends 'Interchange6::Cart::Product';

with 'Djet::Trait::Field::Price';

=head1 NAME

Djet::Shop::Cart::Product

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 node_data

The data node

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

=head2 value

The price, total, ...

=cut

has value => (
	is => 'rw',
	isa => 'Str',
);

sub formatted_price {
    my $self = shift;
    $self->value($self->price);
    return $self->formatted_value(@_);
}

sub formatted_total {
    my $self = shift;
    $self->value($self->total);
    return $self->formatted_value(@_);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

