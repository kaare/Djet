package Djet::Shop::Cart;

use Moose;
use MooseX::NonMoose;
use DBIx::Class::ResultClass::HashRefInflator;

extends 'Interchange6::Cart';
with 'Djet::Part::Log';

=head1 NAME

Djet::Shop::Cart;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 model

The DBIC model

=cut

has model => (
	is => 'ro',
	isa => 'Djet::Model',
);

=head2 uid

User id of the cart

=cut

has uid => (
	is => 'ro',
	isa => 'Str',
	predicate => 'has_uid',
);

=head2 cart_name

Name of the cart

=cut

has cart_name => (
	is => 'ro',
	isa => 'Str',
	default => 'cart',
);

=head2 cart_row

The cart row

=cut

has cart_row => (
	is => 'ro',
	isa => 'Djet::Schema::Result::Djet::Cart',
	lazy_build => 1,
);

sub _build_cart_row {
	my $self = shift;
	my $model = $self->model;
	die "Neither user nor session id" unless $self->has_uid or $model->has_session_id;

	my $where = $self->has_uid ? {uid => $self->uid} : {session_id => $model->session_id};
	my $cart_row = $model->resultset('Djet::Cart')->find($where);
	return $cart_row ? $self->_load_cart($cart_row) : $self->_create_cart;
}

=head1 METHODS

=head2 BUILD

Create the cart

=cut

=head2 save

No-op, as all cart changes are saved through hooks to the database.

=cut

sub save {
	return 1;
}

# creates cart in database
sub _create_cart {
	my $self = shift;
	my $model = $self->model;
	return $model->resultset('Djet::Cart')->create({
		name => $self->name,
		uid => $self->has_uid ? $self->{uid} : 0,
		session_id => $model->has_session_id ? $model->session_id : '',
		name => $self->cart_name,
	});
}

# loads cart from database
sub _load_cart {
	my ($self, $cart_row) = @_;
	# build query for item retrieval
	my $cart_products = $self->model->resultset('Djet::CartProduct')->search({
		cart => $cart_row->code,
	}, {
		result_class => 'DBIx::Class::ResultClass::HashRefInflator',
	});
	$self->seed([map {delete $_->{cart};$_} $cart_products->all]);
	return $cart_row;
}

before add => sub {
	my ($self, %args) = @_;
	my $cart_product;
	my $model = $self->model;
	if ($cart_product = $model->resultset('Djet::CartProduct')->find({
		cart => $self->cart_row->id,
		sku => $args{sku},
	})) {
		$cart_product->update({quantity => $cart_product->quantity + $args{quantity}});
	} else {
		$cart_product = $model->resultset('Djet::CartProduct')->create({
			cart => $self->cart_row->id,
			sku => $args{sku},
			name => $args{name},
			price => $args{price},
			quantity => $args{quantity},
			weight => $args{weight},
			position => 0
		});
	}
};

before update => sub {
	my ($self, %args) = @_;
	my $cart_id = $self->cart_row->id;
	my $model = $self->model;
	while (my ($sku, $qty) = each %args) {
		my $search = {
			cart => $cart_id,
			sku => $sku,
		};
		if (my $cart_product = $model->resultset('Djet::CartProduct')->find($search)) {
			if ($qty) { 
				$cart_product->update({quantity => $qty});
			} else {
				$cart_product->delete;
			}
		}
	}
};

before remove => sub {
	my ($self, %args) = @_;
	my $model = $self->model;
	if (my $cart_product = $model->resultset('Djet::CartProduct')->find({
		cart => $self->cart_row->id,
		sku => $args{sku},
	})) {
		$cart_product->delete;
	}
};

before clear => sub {
	my ($self, %args) = @_;
	$self->model->resultset('Djet::CartProduct')->delete({
		cart => $self->cart_row->id,
		sku => $args{sku},
	});
};

=pod

before products => sub {
	my $self = shift;
	my $products = $self->{products} || return;

	map {$_->{total} = $_->{quantity} * $_->{price}} @$products;
};

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

