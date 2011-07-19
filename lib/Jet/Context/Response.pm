package Jet::Context::Response;

use 5.010;
use Moose;

with 'Jet::Role::Log';

=head1 NAME

Jet::Context::Response - Response Class for Jet::Context

=head1 DESCRIPTION

This is the Response class for L<Jet::Context>.

=head1 SYNOPSIS


=head1 METHODS

=over

=head1 Attributes

=over

=head2 status

=head2 headers

=head2 output

=cut

has 'status'    => (isa => 'Int', is => 'rw', default => 200);
has 'headers' => (isa => 'ArrayRef', is => 'rw', default => [ 'Content-Type' => 'text/html; charset="utf-8"' ]);
has 'output'   => (isa => 'ArrayRef, is =>  'rw', default => [ 'test' ]);
# XXX Default code mockup
# $node - from where?
# render needs some stash values?
# $code = $node->can('render') && return &$code;
#

__PACKAGE__->meta->make_immutable;

__END__
