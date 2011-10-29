package Jet::Engine::File::Upload;

use 5.010;
use Moose;
use File::Copy;
use File::Path;

extends 'Jet::Engine';

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::File::Upload - A file upload engine part

=head1 SYNOPSIS

=head1 METHODS

=head2 data

Receives a list of filenames and creates children below current node

=cut

sub data {
	my $self = shift;
	my $c = Jet::Context->instance();
my $schema = $c->schema;
my $parent_id = $c->node->row->get_column($self->in->{parent_id});
use Jet::Node;
my $parent = Jet::Node->new(
	row => $schema->find_node({ path_id =>  $parent_id })
);
	my $basedir = $c->config->jet->{paths}{image}{file};
	my $req = $c->request;
	for my $upload ($req->uploads->get_all('files')) {
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
__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
