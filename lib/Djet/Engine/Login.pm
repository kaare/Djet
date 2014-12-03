package Djet::Engine::Login;

use 5.010;
use Moose;

extends 'Djet::Engine::Default';

=head1 NAME

Djet::Engine::Login

=head2 DESCRIPTION

A login where the user enters some basic information and a comment. This data is saved in a new node, and emailed to both the site admin and the user self.

Based on the node update role, it includes validation as chosen for the individual fields, and all edit navigation is controlled there.

=head1 METHODS

=head2 allowed_methods

Allow POST for updating (Web::Machine)

=cut

sub allowed_methods {
	return [qw/GET HEAD POST/];
}

=head2 before process_post

This is processed when the login is submitted.

=cut

sub process_post {
	my $self = shift;
	my $params = $self->body->request->body_parameters;
	return $self->response->body($self->view_page) unless my $username = $params->{username} and my $password = $params->{password};
	return $self->response->body($self->view_page) unless $self->acl->check_user(user => $username, password => $password);

	$self->session->{jet_user} = $username;
	my $redirect_uri = delete $self->session->{redirect_uri} // '/';
	$self->response->header('Location' => $redirect_uri);
	return \302;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
