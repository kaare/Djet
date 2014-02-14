package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Treeview Jet::Role::Log/;

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 DESCRIPTION

Jet::Engine::Default is the basic Jet Engine.

It includes the roles L<Jet::Role::Treeview> and L<Jet::Role::Log>.

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
