package Jet::Engine::Config;

use 5.010;
use Moose;

extends 'Jet::Engine::Default';
with qw/Jet::Role::Update::Node Jet::Role::Config::Topmenu/;

=head1 NAME

Jet::Engine - Configure Jet

=head1 DESCRIPTION

Jet::Engine::Config configures Jet data and nodes.

It includes the roles L<Jet::Role::Update::Node> and L<Jet::Role::Config::Topmenu>.

=head1 ATTRIBUTES

=head1 METHODS

=head2 data

Control what to send when it's Jet config

=cut

after data => sub {
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
		$stash->{topmenu} = $self->topmenu;
		$response->template('/config/basenode.tx');
	}
};

=head2 edit_updated

Override the role method to do nothing

=cut

sub edit_updated {}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
