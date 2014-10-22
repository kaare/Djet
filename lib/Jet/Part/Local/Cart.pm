package Jet::Part::Local::Cart;

use 5.010;
use Moose::Role;

use Jet::Shop::Cart;

=head1 NAME

Jet::Part::Local::Cart

=head1 DESCRIPTION

Add cart information to the local object

=head1 ATTRIBUTES

=head2 cart

The cart

=cut

has 'cart' => (
	is => 'ro',
	isa => 'Jet::Shop::Cart',
	lazy_build => 1,
);

sub _build_cart {
	my $self = shift;
	my $session = $self->session;
	my $cart = Jet::Shop::Cart->new(
		schema => $self->schema,
		session_id => $self->session_id,
		uid => $session->{jet_user},
	);
	return $cart;
}

=head2 cart_base_url

The base url of the cart

=cut

has 'cart_base_url' => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $schema = $self->schema;
		my $cart_basetype = $schema->basetype_by_name('cart');
		my $domain_node = $self->domain_node;
		my $cart_row = $schema->resultset('Jet::DataNode')->find({
			basetype_id => $cart_basetype->id,
			node_path => {'<@' => $domain_node->node_path},
		});
		return $cart_row->urify($domain_node);
	},
	lazy => 1,
);

=head2 checkout_base_url

The base url of the checkout page

=cut

has 'checkout_base_url' => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $schema = $self->schema;
		my $checkout_basetype = $schema->basetype_by_name('checkout') or return '';

		my $domain_node = $self->domain_node;
		my $checkout_row = $schema->resultset('Jet::DataNode')->find({
			basetype_id => $checkout_basetype->id,
			node_path => {'<@' => $domain_node->node_path},
		}) or return '';
		return $checkout_row->urify($domain_node);
	},
	lazy => 1,
);

no Moose::Role;

1;

# COPYRIGHT

__END__

