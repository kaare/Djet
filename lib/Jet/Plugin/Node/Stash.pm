package Jet::Plugin::Node::Stash;

use 5.010;
use Moose;

extends 'Jet::Plugin';

with 'Jet::Role::Log';

=head1 NAME

Jet::Node::Stash - Stash some nodes

=head1 SYNOPSIS

=head1 METHODS

=head2 data

Moves a node to a new parent

=head1 PARAMETERS

=head2 container

What container holds the node(s) to start from

default context

=head2 nodes

Which nodes to start from

default node

=head2 path

Path expression to use

=head2 name

What name to use for the result in the stash

=cut

sub data {
	my $self = shift;
	my $c = Jet::Context->instance();
	my $stash = $c->stash;
	# Container is stash or context (default)
	my $container = $self->in->{container} && $self->in->{container} eq 'stash' ? $c->stash : $c;
	my $nodes = $self->in->{nodes} || 'node';
	my $method = $self->in->{method};
	my $params = $self->in->{params};
	my $name = $self->in->{name};
	my @nodes;
	my $node = ref $container eq 'Jet::Context' ? $container->$nodes : $container->{$nodes};
	given (ref $node) {
		when ('ARRAY') {
			for my $nod (@$node) {
				while (my $n = $nod->next(1)) {
					@nodes = (@nodes, @{ $n->$method(%$params)->rows });
				}
			}
		};
		when ('Jet::Node') { @nodes = $node->$method(%$params) };
		when ('Jet::Engine::Result') {
			while (my $n = $node->next(1)) {
				@nodes = (@nodes, @{ $n->$method(%$params) });
			}
		};
	}
	$stash->{$name} = \@nodes;
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
