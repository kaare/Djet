package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';

with qw/
	Jet::Role::Engine
	Jet::Role::Engine::Html
	Jet::Role::Engine::Json
	Jet::Role::Treeview
/;

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 DESCRIPTION

Jet::Engine::Default is the basic Jet Engine.

It includes the roles L<Jet::Role::Engine Jet::Role::Engine::Html>, L<Jet::Role::Engine::Json>, L<Jet::Role::Treeview>.

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
