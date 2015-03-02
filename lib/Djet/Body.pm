package Djet::Body;

use 5.010;
use Moose;

extends 'Djet::Body::Base';

=head1 NAME

Djet::Body

=head1 DESCRIPTION

The Djet Body

Djet::Body is instantiated by Djet::Starter at the beginning of a request cycle.
It holds all the volatile information, as opposed to Djet::Model.

See L<Djet::Body::Base>

=head1 ATTRIBUTES

=head2 stash

The stash keeps data throughout a request cycle

=cut

has stash => (
	isa => 'HashRef',
	traits => ['Hash'],
	is => 'ro',
	lazy => 1,
	default => sub { {} },
	handles => {
		set_stash => 'set',
		clear_stash => 'clear',
	},
);

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
