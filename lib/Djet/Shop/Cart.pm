package Djet::Shop::Cart;

use Moose;
use MooseX::NonMoose;
use DBIx::Class::ResultClass::HashRefInflator;

extends 'Nitesi::Cart';

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

=head2 session_id

Session session_id of the cart

=cut

has session_id => (
	is => 'ro',
	isa => 'Str',
	predicate => 'has_session_id',
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
	die "Neither user nor session id" unless $self->has_uid or $self->has_session_id;

	my $where = $self->has_uid ? {uid => $self->uid} : {session_id => $self->session_id};
	my $cart_row = $self->model->resultset('Djet::Cart')->find($where);
	return $cart_row ? $self->_load_cart($cart_row) : $self->_create_cart;
}

=head1 METHODS

=head2 BUILD

Create the cart

=cut

sub BUILD {
	my $self = shift;
	$self->cart_row;
}

=head2 save

No-op, as all cart changes are saved through hooks to the database.

=cut

sub save {
	return 1;
}

# creates cart in database
sub _create_cart {
	my $self = shift;
	return $self->model->resultset('Djet::Cart')->create({
		name => $self->name,
		uid => $self->has_uid ? $self->{uid} : 0,
		session_id => $self->has_session_id ? $self->session_id : '',
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
	$self->seed([$cart_products->all]);
	return $cart_row;
}

before add => sub {
	my ($self, %args) = @_;
	my $cart_product;
	if ($cart_product = $self->model->resultset('Djet::CartProduct')->find({
		cart => $self->cart_row->id,
		sku => $args{sku},
	})) {
		$cart_product->update({quantity => $cart_product->quantity + $args{quantity}});
	} else {
		$cart_product = $self->model->resultset('Djet::CartProduct')->create({
			cart => $self->cart_row->id,
			sku => $args{sku},
			name => $args{name},
			price => $args{price},
			quantity => $args{quantity},
			position => 0
		});
	}
};

before update => sub {
	my ($self, %args) = @_;
	my $cart_id = $self->cart_row->id;
	while (my ($sku, $qty) = each %args) {
		my $search = {
			cart => $cart_id,
			sku => $sku,
		};
		if (my $cart_product = $self->model->resultset('Djet::CartProduct')->find($search)) {
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
	if (my $cart_product = $self->model->resultset('Djet::CartProduct')->find({
		cart => $self->cart_row->id,
		sku => $args{sku},
	})) {
		$cart_product->delete;
	}
};

=pod

after rename => sub {
	my ($self, @args) = @_;

	unless ($self eq $args[0]) {
		# not our cart
		return;
	}

	$self->{sqla}->update('carts', {name => $args[2]}, {code => $self->{id}});
};

=cut

before clear => sub {
	my ($self, %args) = @_;
	$self->model->resultset('Djet::CartProduct')->delete({
		cart => $self->cart_row->id,
		sku => $args{sku},
	});
};


before items => sub {
	my $self = shift;
	my $items = $self->{items} || return;

	map {$_->{total} = $_->{quantity} * $_->{price}} @$items;
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

