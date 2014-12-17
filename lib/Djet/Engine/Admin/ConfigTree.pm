package Djet::Engine::Admin::ConfigTree;

use 5.010;
use Moose;

extends 'Djet::Engine::Default';

with qw/
	Djet::Part::Engine::Json
	Djet::Part::Treeview
/;

=head1 NAME

Djet::Engine::Admin::ConfigTree

=head1 DESCRIPTION

Djet::Engine::Admin::ConfigTree shows the node tree.

It includes the role L<Djet::Part::Treeview>.

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
