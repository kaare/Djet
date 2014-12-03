package Djet::Part;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part - Base classe for Djet::Parts

=head1 SYNOPSIS

with 'Djet::Part';

=cut

requires qw/stash request basenode response/;

no Moose::Role;

1;

# COPYRIGHT

__END__
