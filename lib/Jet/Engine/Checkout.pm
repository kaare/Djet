package Jet::Engine::Checkout;

use 5.010;
use Moose;
use JSON;

extends 'Jet::Engine::Default';

use Jet::Shop::Cart;

=head1 NAME

Jet::Engine::Checkout

=head2 DESCRIPTION

Handles the checkout process

=head1 ATTRIBUTES

=head2 cart

The cart object

=cut

has cart => (
	is => 'ro',
	isa => 'Jet::Shop::Cart',
	default => sub {
		my $self = shift;
		my $cart = Jet::Shop::Cart->new(
			schema => $self->schema,
			uid => 1,
		);
	},
	lazy => 1,
);

=head2 steps

The checkout steps as fetched from the database and ordered by node_modified

=cut

has 'steps' => (
	is => 'ro',
	isa => 'ArrayRef',
	default => sub {
		my $self = shift;
		$self->add_search();
		my $search = $self->schema->resultset('Jet::DataNode')->search({
			parent_id => $self->basenode->node_id,
		},{
			order_by => node_modified,
		});
		return [ $search->all ];
	},
	lazy => 1,
);

=head2 checkout

The current checkout data

=cut

has checkout => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		return $session->{session} // { wanted_step => 1}
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

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
