package Jet::Part;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Part - Base classe for Jet::Parts

=head1 SYNOPSIS

with 'Jet::Part';

=cut

requires qw/stash request basenode response/;

no Moose::Role;

1;

# COPYRIGHT

__END__
