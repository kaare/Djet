package Jet::Plugin::Node::Pick;

use 5.010;
use Moose;

extends 'Jet::Plugin';

with 'Jet::Role::Log';

=head1 NAME

Jet::Node::Pick - Pick a node from a stash array

=head1 SYNOPSIS

=head1 METHODS

=head2 data

Pick a node from a stash array

The node will be deleted from the array

=head1 PARAMETERS

=head2 nodes

Which nodes to be Picked together

=head2 column

What column to use as key

=head2 value

The key value

=head2 name

What name to use for the result in the stash

=cut

sub data {
	my $self = shift;
	my $parms = $self->parameters;
	my $nodes = $parms->{nodes};
	my $column = $parms->{column};
	my $value = $parms->{value};
	my $name = $parms->{name};
	return unless $nodes and ref $nodes eq 'ARRAY';

	my $node;
	$self->stash->{$nodes} = [ grep {	my $ok = 1;if ($_->row->get_column($column) eq $value){$node = $_;$ok = 0};$ok} @{ $nodes }] ;
	$self->stash->{$name} = $node;
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
