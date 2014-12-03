package Djet::Exception;

use 5.010;
use Moose;
use namespace::autoclean;

extends 'HTTP::Throwable::Factory';

with 'Djet::Role::Log';

=head1 NAME

Djet::Exception - Djet Exceptions

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
