package Jet::Plugin::Node::MoveTo;

use 5.010;
use Moose;
use File::Copy;
use File::Path;

extends 'Jet::Plugin';

with 'Jet::Role::Log';

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS

=head1 METHODS

=head2 data

Moves a node to a new parent

=head1 PARAMETERS

=head2 child_id

Where to find the child

=head2 parent_id

Where to find the parent. Default the current parent

=head1 TODO

Waiting for $c->rest with deserialized content. Instead of JSON, the content should be
my $content = $c->rest->content;

=cut

sub data {
	my $self = shift;
	my $c = Jet::Context->instance();
	my ($container, $child_location) = split /\./, $self->in->{child_id};
my $req = $c->request;
use JSON;
my $content = JSON->new->decode($req->content);
	my $child_id = $content->{$child_location}; 
#	$c->node->move_child($child_id)
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
