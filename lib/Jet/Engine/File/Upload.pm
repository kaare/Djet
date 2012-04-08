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
	## !! request should be available to any engine part.
	## It might be a good thing to have a config engine part to avoid this clutter
	my $c = Jet::Context->instance();
	my $basedir = $c->config->jet->{paths}{image}{file};
	my $req = $c->request;
	# !!
	## !! Should be a separate engine part, or part of Node::Stash
	my $box = $c->nodebox;
	my $parent_id = $c->node->get_column($self->parameters->{parent_id});
	my $parent = $box->find_node({ node_id =>  $parent_id });
	## !!
	for my $upload ($req->uploads->get_all('files')) {
		my $uploadfile = $upload->path;
		my $photo = {
			title => $upload->filename,
			basetype => 'photo',
			content_type => $upload->content_type,
			name => $upload->filename,
		};
		my $photo_node = $parent->add_child($photo);
		my $target_id = $photo_node->get_column('id');
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
