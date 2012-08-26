package Jet::Engine::Part::Node::BC;

use 5.010;
use Moose;

extends 'Jet::Engine::Part';

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Part::Node::BC - Stash breadcrumbs

=head1 SYNOPSIS

Stash breadcrumbs

=head1 ATTRIBUTES

=cut

has stashname => (
	is => 'ro',
	isa => 'Str',
);

=head1 METHODS

=head2 run

=cut

sub run {
	my $self = shift;
	my $stashname = $self->stashname;
	my $basenode = $self->basenode;
	$self->stash->{$stashname} = $self->parents($basenode);
}

=head2 parents

Return the parents of the basenode

We know they're already on the stack
 
=cut

sub parents {
	my ($self, $basenode) = @_;
	return $basenode->ancestors;
}

no Moose::Role;

1;

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
