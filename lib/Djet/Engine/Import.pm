package Jet::Engine::Import;

use 5.010;
use Moose;
use JSON;
use File::Copy;
use File::Path;
use Job::Machine::Client;

extends 'Jet::Engine::Default';

=head1 NAME

Jet::Engine::Import

=head1 DESCRIPTION

Jet::Engine::Import controls import of files to the system.

It displays a form with one or more upload files and accepts a POST request with that form.

The files are stored in a private path, a node is created for each, and an import job is created, using Job::Machine.

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
	eval { $self->schema->txn_do($transaction) };
	my $error=$@;

	if ($error) {
		$self->config->log->debug($error);
		$self->stash->{message} = $error;
	} else {
		return $self->basenode->node_path;
	}
}

=head2 create_nodes

Create the Jet nodes. Optionally (if the import node has a queue defined), create a JobMachine task

=cut

sub create_nodes {
	my $self = shift;
	my $schema = $self->schema;
	my $dbh = $schema->storage->dbh;
	my $queue = $self->basenode->queue->value;
	my $client = Job::Machine::Client->new(
		dbh => $dbh,
		queue => $queue,
	) if defined($queue);

	my $parent_id = $self->basenode->id;
	my $uploadtype = $schema->basetype_by_name('import');
	my $basetype_id = $uploadtype->id;
	my $request = $self->body->request;
	for my $upload ($request->uploads->get_all('uploadedfile')) {
		my $uploadfile = $upload->path;
		my $data = {
			parent_id => $parent_id,
			basetype_id => $basetype_id,
			name => $upload->filename,
			title => $upload->filename,
			datacolumns => $self->json->encode({ mime_type => $upload->content_type}),
		};
		my $file_node = $schema->resultset('Jet::DataNode')->create($data);
		$file_node->discard_changes;
		my $node_id = $file_node->node_id;
		my $file_path = $self->file_placement($upload->path, $self->basenode->path, $node_id);
		$file_node->update({part => $node_id});
		if (defined($queue)) {
			$data->{file_path} = $file_path;
			$client->send($data);
		}
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
