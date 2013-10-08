package Jet::Part::Children;

use 5.010;
use Moose::Role;
use namespace::autoclean;

with 'Jet::Part';

=head1 NAME

Jet::Part::Children - Put the children of a node(default basenode) on the stash

=head1 ATTRIBUTES

=cut

=head1 METHODS

=head2 data

Puts children nodes on the stash (as $self->stash->{children};

=cut

sub data {
	my $self = shift;
	my $nodename = $self->stash->{nodename} // 'basenode';
	my $childrenname = $self->stash->{childrenname} // 'children';
	$self->stash->{$childrenname} = $self->stash->{$nodename}->children;
}

no Moose::Role;

1;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2013 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
