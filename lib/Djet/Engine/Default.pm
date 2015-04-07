package Djet::Engine::Default;

use 5.010;
use Moose;

extends 'Djet::Engine';

with qw/
	Djet::Part::Engine
	Djet::Part::Engine::Html
	Djet::Part::Engine::Json
	Djet::Part::Treeview
/;

=head1 NAME

Djet::Engine - Default Djet Engine

=head1 DESCRIPTION

Djet::Engine::Default is the basic Djet Engine.

It includes the roles L<Djet::Part::Engine Djet::Part::Engine::Html>, L<Djet::Part::Engine::Json>, L<Djet::Part::Treeview>.

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
