package Djet::Engine::Default;

use 5.010;
use Moose;

extends 'Djet::Engine';

with qw/
	Djet::Role::Engine
	Djet::Role::Engine::Html
	Djet::Role::Engine::Json
	Djet::Role::Treeview
/;

=head1 NAME

Djet::Engine - Default Djet Engine

=head1 DESCRIPTION

Djet::Engine::Default is the basic Djet Engine.

It includes the roles L<Djet::Role::Engine Djet::Role::Engine::Html>, L<Djet::Role::Engine::Json>, L<Djet::Role::Treeview>.

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
