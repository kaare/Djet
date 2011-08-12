package Jet::Plugin::File::Upload;

use 5.010;
use Moose;
use File::Copy;
use File::Path;

extends 'Jet::Plugin';

with 'Jet::Role::Log';

sub data {
	my $self = shift;
	my $c = Jet::Context->instance();
my $schema = $c->schema;
my $parent_id = $c->node->row->get_column($self->in->{parent_id});
use Jet::Node;
my $parent = Jet::Node->new(
	row => $schema->find_node({ path_id =>  $parent_id })
);
	my $basedir = $c->config->{config}{paths}{image}{file};
	my $req = $c->request;
	for my $upload ($req->uploads->get_all('files')) {
		debug($upload->filename);

		my $uploadfile = $upload->path;
		my $photo = {
			title => $upload->filename,
			basetype => 'photo',
			content_type => $upload->content_type,
			filename => $upload->filename,
		};
		my $photo_node = $parent->add_child($photo);
		my $target_id = $photo_node->row->get_column('id');
		my $td = substr($target_id,-4);
		$td .= '_' x ( 4 - length( $td ) );
		my $targetdir = substr($td,-2).'/'.substr($td,-4,2);
		my $targetpath = join '/', $basedir, $targetdir, $target_id;
		mkpath($targetpath);
        move $upload->path, join '/', $targetpath, $upload->filename;
	}
}

no Moose::Role;

1;
