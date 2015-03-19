package Djet::Engine::Cart;

use 5.010;
use Moose;
use JSON;

extends 'Djet::Engine::Default';

use Djet::Shop::Cart;

=head1 NAME

Djet::Engine::Cart

=head2 DESCRIPTION

Handles add, edit, delete of cart items

=head1 ATTRIBUTES

=head2 cart

The cart object

=cut

has cart => (
	is => 'ro',
	isa => 'Djet::Shop::Cart',
	default => sub {
		my $self = shift;
		return $self->model->payload->cart;
	},
	lazy => 1,
);

=head1 METHODS

=head2 allowed_methods

Allow POST for updating (Web::Machine)

=cut

sub allowed_methods {
	return [qw/GET HEAD POST/];
}

=head2 post_is_create

=cut

sub post_is_create {
	my $self = shift;
	my $data_row = $self->cart_line;
	return unless $data_row or ref $data_row ne 'HASH';

	$self->cart->add(%$data_row);
	return;
}

=head2 cart_line

Returns the hashref to be submitted to cart->add

Default is an empty hashref

=cut

sub cart_line { { } }

=head2 process_post

=cut

sub process_post {
	my ($self) = @_;
	my $values = $self->minicart;
	return unless $values or ref $values;

	$self->response->body($values);
}

=head2 minicart

Returns the body content to be returned after an item has been added

Default is json encoded cart values:

	count
	quantity
	subtotal
	total

=cut

sub minicart {
	my ($self) = @_;
	my $cart = $self->cart;
	my $values;
	$values->{$_} = $cart->$_ for qw/count quantity subtotal total/;
	$self->content_type('json');
	return JSON->new->encode($values);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
