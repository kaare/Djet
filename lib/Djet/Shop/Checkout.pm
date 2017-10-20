package Djet::Shop::Checkout;

use 5.010;
use Moose;

with 'Djet::Part::Basic';

=head1 NAME

Djet::Shop::Checkout

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

=head2 step

The current step

=cut

has 'step' => (
	is => 'ro',
	isa => 'Djet::Schema::Result::Djet::DataNode',
);

=head2 mailer

Djet mailer. In case the checkout step needs to alert someone

=cut

has mailer => (
	is => 'ro',
	isa => 'Djet::Mail',
);

=head1 METHODS

=head2 data

=cut

sub data { }

sub cleanup { }

=head2 has_all_data

=cut

sub has_all_data { 1 }

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
