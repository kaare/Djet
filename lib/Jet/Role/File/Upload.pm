package Jet::Role::File::Upload;

use 5.010;
use Moose::Role;

=head1 NAME

Jet::Role::File::Upload - Role for uploading a file

=head1 SYNOPSIS

with 'Jet::Role::Person::Login';

=head1 METHODS

=head2 file_location

Get the real location in the file system

=cut

sub file_location {
	my $self = shift;
	my $c = Jet::Context->instance();
	my $basedir = $c->config->jet->{paths}{image}{url};
	my $target_id = $self->row->get_column('id');
	my $td = substr($target_id,-4);
	$td .= '_' x ( 4 - length( $td ) );
	my $targetdir = substr($td,-2).'/'.substr($td,-4,2);
	return join '/', '', $basedir, $targetdir, $target_id, $self->row->get_column('filename');
}

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
