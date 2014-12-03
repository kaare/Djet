package Djet::Part::Local::Basic;

use 5.010;
use Moose::Role;

use Djet::Shop::Cart;

=head1 NAME

Djet::Part::Local::Basic

=head1 DESCRIPTION

Add information about basic types to the local object

Basic Jet types are

	Cart
	Search
	User

=head1 ATTRIBUTES

=head2 cart

The cart

=cut

has 'cart' => (
	is => 'ro',
	isa => 'Djet::Shop::Cart',
	lazy_build => 1,
);

sub _build_cart {
	my $self = shift;
	my $session = $self->session;
	my $cart = Djet::Shop::Cart->new(
		schema => $self->schema,
		session_id => $self->session_id,
		uid => $session->{djet_user} // '',
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
		my $cart_row = $schema->resultset('Djet::DataNode')->find({
			basetype_id => $cart_basetype->id,
			node_path => {'<@' => $domain_node->node_path},
		});
		return $self->urify($cart_row);
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
		my $checkout_row = $schema->resultset('Djet::DataNode')->find({
			basetype_id => $checkout_basetype->id,
			node_path => {'<@' => $domain_node->node_path},
		}) or return '';
		return $self->urify($checkout_row);
	},
	lazy => 1,
);

=head2 search_base_url

The base url of the search node

=cut

has 'search_base_url' => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $schema = $self->schema;
		my $search_basetype = $schema->basetype_by_name('search');
		my $domain_node = $self->domain_node;
		my $search_row = $schema->resultset('Djet::DataNode')->find({
			basetype_id => $search_basetype->id,
			node_path => {'<@' => $domain_node->node_path},
		});
		return $self->urify($search_row);
	},
	lazy => 1,
);

=head2 user

The current user

=cut

has 'user' => (
	is => 'ro',
	isa => 'Maybe[Djet::Schema::Result::Djet::DataNode]',
	lazy_build => 1,
);

sub _build_user {
	my $self = shift;
	my $user = $self->session->{djet_user} // return;

	my $schema = $self->schema;
	my $user_basetype = $schema->basetype_by_name('user') or return '';

	my $user_row = $schema->resultset('Djet::DataNode')->find({
		basetype_id => $user_basetype->id,
		part => $user,
	}) or return;

	return $user_row;
}

no Moose::Role;

1;

# COPYRIGHT

__END__

