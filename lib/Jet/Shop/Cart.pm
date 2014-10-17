package Jet::Shop::Cart;

use Moose;
use DBIx::Class::ResultClass::HashRefInflator;

use base 'Nitesi::Cart';

=head1 NAME

Jet::Shop::Cart;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 schema

The DBIC schema

=cut

has schema => (
	is => 'ro',
	isa => 'Jet::Schema',
);

=head2 uid

User id of the cart

=cut

has uid => (
	is => 'ro',
	isa => 'Int',
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
	isa => 'Jet::Schema::Result::Jet::Cart',
	lazy_build => 1,
);

=head1 METHODS

=head2 load

Loads cart from database.

parameters: uid, session_id

=cut

sub _build_cart_row {
	my $self = shift;
	die "Neither user nor session id" unless $self->has_uid or $self->has_session_id;

	my $where = $self->has_uid ? {uid => $self->uid} : {session_id => $self->session_id};
	my $cart_row = $self->schema->resultset('Jet::Cart')->find($where);
	return $cart_row ? $self->_load_cart($cart_row) : $self->_create_cart;
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
	return $self->schema->resultset('Jet::Cart')->create({
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
	my $cart_products = $self->schema->resultset('Jet::CartProduct')->search({
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
	if ($cart_product = $self->schema->resultset('Jet::CartProduct')->find({
		cart => $self->cart_row->id,
		sku => $args{sku},
	})) {
		$cart_product->update({quantity => $cart_product->quantity + $args{quantity}});
	} else {
		$cart_product = $self->schema->resultset('Jet::CartProduct')->create({
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
	if (my $cart_product = $self->schema->resultset('Jet::CartProduct')->find({
		cart => $self->cart_row->id,
		sku => $args{sku},
	})) {
		$cart_product->update({quantity => $args{quantity}});
	}
};

before remove => sub {
	my ($self, %args) = @_;
	if (my $cart_product = $self->schema->resultset('Jet::CartProduct')->find({
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
	$self->schema->resultset('Jet::CartProduct')->delete({
		cart => $self->cart_row->id,
		sku => $args{sku},
	});
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

