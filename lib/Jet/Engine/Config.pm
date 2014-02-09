package Jet::Engine::Config;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Update::Node Jet::Role::Treeview Jet::Role::Log/;

=head1 NAME

Jet::Engine - Configure Jet

=head1 DESCRIPTION

Jet::Engine::Config configures Jet data and nodes.

=head1 ATTRIBUTES

=head2 parts

This is the engine parts

=cut

has _parts => (
	traits	=> [qw/Jet::Trait::Engine/],
	is		=> 'ro',
	isa		=> 'ArrayRef',
	parts => [
	],
);

=head1 METHODS

=head2 data

Control what to send when it's Jet config

=cut

before data => sub {
	my $self = shift;
	my $response = $self->response;
	my $stash = $self->stash;
	if ($self->response->data_nodes->rest_path eq '_jet_config') {
		$self->edit;
		$stash->{node} = $self->basenode;
		$stash->{request} = $self->request;

		# Return
		$response->template('basetype/jet/config/basenode_edit.tx');
	} else {
		$response->template('basetype/jet/config.tx');
	}
};

=head2 edit_updated

Override the role method to do nothing

=cut

sub edit_updated {}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
