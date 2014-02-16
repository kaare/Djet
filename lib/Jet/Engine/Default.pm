package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Treeview Jet::Role::Breadcrumbs Jet::Role::Log/;

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 DESCRIPTION

Jet::Engine::Default is the basic Jet Engine.

It includes the roles L<Jet::Role::Treeview> and L<Jet::Role::Log>.

=head1 METHODS

=head2 data

=cut

before data => sub {
	my $self = shift;
	my $stash = $self->stash;
	$stash->{node} = $self->basenode;
	$stash->{nodes} = $self->response->data_nodes;
	$stash->{request} = $self->request;
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
