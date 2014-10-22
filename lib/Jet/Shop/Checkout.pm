package Jet::Shop::Checkout;

use 5.010;
use Moose;

with 'Jet::Role::Basic';

=head1 NAME

Jet::Shop::Checkout

=head2 DESCRIPTION

Base class for checkout subhandlers

=head1 ATTRIBUTES

=head2 checkout

The checkout data

=cut

has checkout => (
	is => 'ro',
	isa => 'HashRef',
);

=head1 METHODS

=head2 has_all_data

=cut

sub has_all_data { }

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
