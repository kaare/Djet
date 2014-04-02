package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';

with qw/
	Jet::Role::Engine::Html
	Jet::Role::Engine::Json
	Jet::Role::Treeview
/;

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 DESCRIPTION

Jet::Engine::Default is the basic Jet Engine.

It includes the roles L<Jet::Role::Treeview> and L<Jet::Role::Log>.

=head1 METHODS

=cut

sub to_html {
	my $self = shift;
	my $stash = $self->stash;
	$stash->{node} = $self->basenode;
	$stash->{nodes} = $self->datanodes;
	$stash->{request} = $self->request;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
