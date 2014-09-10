package Jet::Engine::ConfigTree;

use 5.010;
use Moose;

extends 'Jet::Engine::Default';

with qw/
	Jet::Role::Engine::Json
	Jet::Role::Treeview
/;

=head1 NAME

Jet::Engine::ConfigTree

=head1 DESCRIPTION

Jet::Engine::ConfigTree shows the node tree.

It includes the role L<Jet::Role::Treeview>.

=head1 ACCESSORS

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
