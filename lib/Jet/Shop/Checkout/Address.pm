package Jet::Shop::Checkout::Address;

use 5.010;
use Moose;

extends 'Jet::Shop::Checkout';

=head1 NAME

Jet::Shop::Checkout::Address

=head2 DESCRIPTION

Handles the address in the checkout process

=cut

sub has_all_data {
	my $self = shift;
	my $stash = $self->stash;
	my $params = $self->request->body_parameters;
	return 1;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
