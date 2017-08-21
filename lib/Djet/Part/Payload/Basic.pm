package Djet::Part::Payload::Basic;

use 5.010;
use Moose::Role;

use Djet::Shop::Cart;

=head1 NAME

Djet::Part::Payload::Basic

=head1 DESCRIPTION

Add commonly used attributes to the payload object

Attributes are

	breadcrumbs

Add information about basic types to the payload object

Basic Djet types are

	Cart
	Search
	User

=head1 ATTRIBUTES

=head2 breadcrumbs

Return the data nodes in reverse order.

The nodes "over" the domain node will be omitted.

The current node is omitted.

If the node's datatype has a breadcrumbs attribute, it will be omitted.

=cut

has 'breadcrumbs' => (
	is => 'ro',
	isa => 'ArrayRef',
	lazy_build => 1,
);

sub _build_breadcrumbs {
	my $self = shift;
	my $model = $self->model;
	my @datanodes = @{ $model->datanodes };
	shift @datanodes;
	my $domain_node = $self->domain_node;
	my $domain_found = 0;
	return [ reverse grep {
		my $use_it = (!$domain_found &&
		!$_->basetype->attributes->{breadcrumbs} &&
		$_->part ne 'index.html');
		$domain_found ||= $domain_node->id == $_->id;
		$use_it;
	} @datanodes ];
}

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
	my $model = $self->model;
	my $session = $model->session;
	my $cart = Djet::Shop::Cart->new(
		model => $model,
		session_id => $model->session_id,
		uid => $session->{djet_user} // '',
	);
	$cart->cart_row; # Necessary for some unknown reason
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
		my $model = $self->model;
		my $cart_basetype = $model->basetype_by_name('cart');
		my $domain_node = $self->domain_node;
		my $cart_row = $model->resultset('Djet::DataNode')->find({
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
		my $model = $self->model;
		my $checkout_basetype = $model->basetype_by_name('checkout') or return '';

		my $domain_node = $self->domain_node;
		my $checkout_row = $model->resultset('Djet::DataNode')->find({
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
		my $model = $self->model;
		my $search_basetype = $model->basetype_by_name('search');
		my $domain_node = $self->domain_node;
		my $search_row = $model->resultset('Djet::DataNode')->find({
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
	my $model = $self->model;
	my $user = $model->session->{djet_user} // return;

	my $user_basetype = $model->basetype_by_name('user') or return '';

	my $user_row = $model->resultset('Djet::DataNode')->find({
		basetype_id => $user_basetype->id,
		part => $user,
	}) or return;

	return $user_row;
}

=head2 logout_node

The logoout node

If there is a logout node in the current domain, it will be used. Otherwise, any logout node (there's probably only one) is used.

=cut

has 'logout_node' => (
	is => 'ro',
	isa => 'Maybe[Djet::Schema::Result::Djet::DataNode]',
	lazy_build => 1,
);

sub _build_logout_node {
	my $self = shift;
	my $model = $self->model;
	my $logout_basetype = $model->basetype_by_name('logout') or return;

	my $domain_basetype = $model->basetype_by_name('domain');
	my $domain_node = $model->datanode_by_basetype($domain_basetype);
	my $find = {
		basetype_id => $logout_basetype->id,
		node_path => {'<@' => [$domain_node->node_path, '/']},
	};
	my $options = {
		order_by => \'length(node_path)',
		rows => 1,
	};
	return $model->resultset('Djet::DataNode')->find($find, $options);
}

no Moose::Role;

1;

# COPYRIGHT

__END__

