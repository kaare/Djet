package Djet::Body::Small;

use 5.010;
use Moose;

extends 'Djet::Body::Base';

=head1 NAME

Djet::Body::Small

=head1 DESCRIPTION

Djet::Body is instantiated by Djet::Starter at the beginning of a request cycle.
It holds all the volatile information, as opposed to Djet::Model.

Djet::Body::Small omits the stash to avoid circular references.

See L<Djet::Body::Base>

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
