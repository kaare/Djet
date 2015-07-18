package Djet::Engine::Import;

use 5.010;
use Moose;
use JSON;
use File::Copy;
use File::Path;

extends 'Djet::Engine::Default';

with qw/
	Djet::Part::Job::Client
/;

=head1 NAME

Djet::Engine::Import

=head1 DESCRIPTION

Djet::Engine::Import controls import of files to the system.

It displays a form with one or more upload files and accepts a POST request with that form.

The files are stored in a private path, and for each file a node is created, and an import job is (optionally) created, using Job::Machine.

The jobs are created if there is a queue name on the import node. If there isn't, it's supposed that the file is just to be uploaded
with no extra processing.

=head1 ATTRIBUTES

=head2 json

JSON Accessor 

=cut

has 'json' => (
	is => 'ro',
	isa => 'JSON',
	default => sub { JSON->new },
);

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

=head2 upload_file

=cut

sub upload_file { }

=head2 post_is_create

We will create a new import file node

=cut

sub post_is_create { 1 }

=head2 create_path

Process the POST request for creating a node

=cut

sub create_path {
	my $self = shift;
	my $transaction = sub {
		$self->create_nodes;
	};
	eval { $self->model->txn_do($transaction) };
	my $error=$@;

	my $model = $self->model;
	if ($error) {
		$model->config->log->debug($error);
		$model->stash->{message} = $error;
	} else {
		return $model->basenode->node_path;
	}
}

=head2 create_nodes

Create the Djet nodes. Optionally (if the import node has a queue defined), create a JobMachine task

The mime_type and (private) file_path is remembered on the data node.
All POST parameters are saved in the job, together with the node_id of the file node (upload_node_id),
and the node_id of the import node (import_node_id).

=cut

sub create_nodes {
	my $self = shift;
	my $model = $self->model;
	my $client = $self->jobclient;

	my $parent_id = $model->basenode->id;
	my $uploadtype = $model->basetype_by_name('upload');
	my $basetype_id = $uploadtype->id;
	my $request = $model->request;
	for my $upload ($request->uploads->get_all('uploadedfile')) {
		my $uploadfile = $upload->path;
		my $datacolumns = {
			mime_type => $upload->content_type,
		};
		my $file_node = $model->resultset('Djet::DataNode')->create({
			parent_id => $parent_id,
			basetype_id => $basetype_id,
			name => $upload->filename,
			title => $upload->filename,
			datacolumns => $datacolumns,
		});

		$file_node->discard_changes;
		my $node_id = $file_node->node_id;
		my $file_path = $self->file_placement($upload->path, $model->basenode->path, $node_id);
		$datacolumns->{file_path} = $file_path;

		$file_node->update({
			part => $node_id,
			datacolumns => $datacolumns,
		});

		my $jobdata = $request->body_parameters->mixed;
		$jobdata->{upload_node_id} = $node_id;
		$jobdata->{import_node_id} = $model->basenode->node_id;
		$client->send($jobdata);
	}
}

=head2 file_placement

Returns the path to the file

=cut

sub file_placement {
	my ($self, $source_path, $basedir, $target_id) = @_;
	my $td = substr($target_id,-4);
	$td .= '_' x ( 4 - length( $td ) );
	my $targetdir = substr($td,-2).'/'.substr($td,-4,2);
	my $targetpath = join '/', $basedir, $targetdir, $target_id;
	mkpath($targetpath);
	my $file_path = join '/', $targetpath, $target_id;
	move $source_path, $file_path;
	return $file_path;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
