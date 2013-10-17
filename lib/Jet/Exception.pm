package Jet::Exception;

use 5.010;
use Moose;
use namespace::autoclean;

extends 'HTTP::Throwable::Factory';

with 'Jet::Role::Log';

=head1 NAME

Jet::Exception - Jet Exceptions

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
