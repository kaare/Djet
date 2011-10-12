package Jet::Engine::Node::Stash;

use 5.010;
use Moose;

extends 'Jet::Engine';

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

=head2 params

Param expression to use

=head2 name

What name to use for the result in the stash

=cut

sub data {
	my $self = shift;
	my $parms = $self->parameters;
	my $node_name = $parms->{nodes} || 'node';
	my $method = $parms->{method};
	my $params = $parms->{params};
	my $name = $parms->{name};
	my @nodes;
	my $nodes = $self->node;#ref $container eq 'Jet::Context' ? $container->$nodes : $container->{$nodes};
	given (ref $nodes) {
		when ('ARRAY') {
			for my $node (@$nodes) {
				@nodes = (@nodes, @{ $node->$method(%$params) });
			}
		};
		when ('Jet::Node') { @nodes = @{ $nodes->$method(%$params) }};
	}
	$self->stash->{$name} = \@nodes;
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
