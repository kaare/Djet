package Djet::Part::Upload;

use 5.010;
use Moose::Role;
use namespace::autoclean;

use File::Copy;
use File::Path;
use List::Util   qw[ first ];

with 'Djet::Part';

=head1 NAME

Djet::Part::File

=head1 DESCRIPTION

A role to help uploading a file to a node.

=head1 METHODS

=head2 part_upload_column

Returns the name of the datacolumns where the upload information should go

=cut

sub part_upload_column {
    my $self = shift;
    if (my $object = $self->object) {
        my $type = $self->object->basetype;
        if ( my $filecol = first { $_->{type} eq 'File' } @{ $type->datacolumns } ) {
            return $filecol->{name};
        }
    }
    # Fallback to 'image'
    return 'image';
}

=head2 part_upload_location

Returns the path name where the upload file should go

=cut

sub part_upload_location {
    my $self = shift;
    if (my $object = $self->object) {
        my $type = $self->object->basetype;
        if ( my $filepath = $type->attributes->{file_path}  ) {
            return $filepath;
        }
    }
    # Fallback
    return 'file/location';
}

=head2 post_is_create

Attach to after, makes sure the upload column is handled

=cut

after 'post_is_create' => sub {
	my $self = shift;
    my $model = $self->model;
	my $request = $model->request;
	my $parameters = $request->parameters;
    my $colname = $self->part_upload_column;

    my $object = $self->object;
    my $datacolumns = $object->datacolumns;
    $datacolumns->{$colname} = $self->save_file;
    $object->update({datacolumns => $datacolumns});
};

=head2 save_file


=cut

sub save_file {
	my $self = shift;
	my $model = $self->model;
	my $request = $model->request;
	my $upload = $request->uploads->{image} or return;
	my $uploadfile = $upload->path;

    my $upload_dir = $self->part_upload_location;
	my $target_dir = join '/', $upload_dir, $self->object->id;
	mkpath($target_dir);
	my $file_path = join '/', $target_dir, $upload->filename;
	move $uploadfile, $file_path;
    return {
        mime_type => $upload->content_type,
        filename => $upload->filename,
        path => $file_path,
    };
}

no Moose::Role;

1;

# COPYRIGHT

__END__
