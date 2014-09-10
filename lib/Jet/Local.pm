package Jet::Local;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

with 'Jet::Role::Basic';

=head1 NAME

Jet::Local

=head1 DESCRIPTION

Jet::Local is a base class for local_class.

The purpose of this is to have a class that is put on the stash and that can contain
anything you'd like.

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

