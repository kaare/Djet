package Djet::Engine::Admin::File;

use 5.010;
use Moose;
use File::Basename;
use File::Copy "move";
use File::Path;

extends 'Djet::Engine::Default';

=head1 NAME

Djet::Engine::Admin::File

=head1 DESCRIPTION

Djet::Engine::Admin::File handles maintenance of files in Djet.

It displays a form with one or more upload files and accepts a POST request with that form.

The files are stored in the public path, decided by the chosen file in the interface 

=head1 METHODS

=head2 BUILD

Tell the machine that we can handle html

=cut

after BUILD => sub {
	my $self = shift;
	$self->add_accepted_content_type( { 'multipart/form-data' => 'upload_file' });
};

=head2 allowed_methods

Allow POST for updating (Web::Machine)

=cut

sub allowed_methods {
	return [qw/GET POST/];
}

=head2 post_is_create

No new node is created

=cut

sub post_is_create { 0 }

=head2 process_post

Process the POST request for handling an upload

=cut

sub process_post {
	my $self = shift;
	my $model = $self->model;
	my $request = $model->request;
	my $file_name = $self->model->request->parameters->{upload_path} or return 1;

	my ($name,$path,$suffix) = fileparse($file_name);
	for my $upload ($request->uploads->get_all('uploadedfile')) {
		move $upload->path, $path . $upload->filename;
		my $destination = join '/', $model->config->app_root, $model->basenode->nodedata->path, $path, $upload->filename;
		move $upload->path, $destination;
	}
	$self->response->body($self->view_page);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
