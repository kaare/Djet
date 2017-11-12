package Djet::Part::File;

use 5.010;
use Moose::Role;
use namespace::autoclean;

use DirHandle;

with 'Djet::Part';

=head1 NAME

Djet::Part::File

=head1 DESCRIPTION

Return a list of directories, and a list of files in a given directory

=head1 METHODS

=head2 file_list

Takes a directory as argument, and returns a list of directories, and a list
of files in that directory.

Works from the app directory root

=cut

sub file_list {
    my ($self, $dir) = @_;
    my $model = $self->model;
    my $fulldir = join '/', $model->config->app_root, $dir;
    my $dh = DirHandle->new($fulldir);
    my (@dirs, @files);
    while (defined(my $ent = $dh->read)) {
        next if $ent eq '.' or $ent eq '..';
        my $type = -d "$dir/$ent" ? \@dirs : \@files;
        push @$type, $ent;
    }
    return \@dirs, \@files;
}

no Moose::Role;

1;

# COPYRIGHT

__END__
