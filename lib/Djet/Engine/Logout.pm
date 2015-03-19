package Djet::Engine::Logout;

use 5.010;
use Moose;

extends 'Djet::Engine::Default';

=head1 NAME

Djet::Engine::Logout

=head2 DESCRIPTION

Removes the user from the session

=head1 METHODS

=head2 before data

Remove the user's session, and redirect to whatever was set as redirect_uri, or to /

=cut

before 'data' => sub  {
	my $self = shift;
	my $model = $self->model;
	my $redirect_uri = delete $model->session->{redirect_uri} // '/';
	delete $model->session->{djet_user};
	$self->response->header('Location' => $redirect_uri);
	$self->return_value(\302);
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
