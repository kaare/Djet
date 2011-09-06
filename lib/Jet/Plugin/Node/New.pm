package Jet::Plugin::Node::New;

use 5.010;
use Moose;

extends 'Jet::Plugin';

with 'Jet::Role::Log';

=head1 NAME

Jet::Plugin::Node::New - Add a new node to a parent

=head1 SYNOPSIS

=head1 METHODS

=head2 data

Moves a node to a new parent

=head1 PARAMETERS

=head2 parent_id

Where to find the parent. Default the current parent

=cut

# XXX TODO names of other data items

sub data {
	my $self = shift;
	my $c = Jet::Context->instance();
	my $container = $self->in->{container} && $self->in->{container} eq 'stash' ? $c->stash : $c;
	my $title_name = $self->in->{title};
	my $title = $c->request->param($title_name);
	my $basetype = $self->in->{basetype};
	return unless $basetype and $title;

	$c->node->add_child({basetype => $basetype, title => $title})
}

no Moose::Role;

1;

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
