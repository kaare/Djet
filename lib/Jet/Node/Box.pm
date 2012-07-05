package Jet::Node::Box;

use 5.010;
use Moose;

use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Node::Box - A box of Nodes

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 nodes

The nodes

=cut

has nodes => (
	isa => 'ArrayRef[Jet::Node]',
	is => 'ro',
	writer => '_node',
);

=head1 METHODS

=head2 BUILD

Require Jet::Node. use would make a circular dependency.

=cut

sub BUILD {
	my $self = shift;
	require 'Jet/Node.pm';
}

=head2 find_node

Accepts a hashref and returns a Jet::Node if found

=cut

sub find_node($) {
	my ($self, $args) = @_;
	my $c = Jet::Context->instance;
	my $schema = $c->schema;
	my $nodedata = $schema->find_nodepath($args);
	return  $nodedata ? Jet::Node->new(row => $nodedata) : undef;
}

=head2 find_node_path

Accepts an url and returns a Jet::Node if the url points to a valid path in the system.

If not found, it goes one step up from find_node and tries to find something consistent with the path

=cut

sub find_node_path($) {
	my ($self, $path) = @_;
	$path =~ s|^/?(.*)$|$1|; # Remove first character if slash
	my $c = Jet::Context->instance;
	my $schema = $c->schema;
	my $nodedata = $schema->find_node({ node_path =>  $path });
	return unless $nodedata;

	my $baserole = $c->basetypes->{$nodedata->{basetype_id}}->{role};
	return Jet::Node->with_traits($baserole)->new(
		row => $nodedata,
	);

	# Find node at one level up. See if there is a path expression on that node
	$path =~ m|(.*)/(\w+)$|;
	my $node_path = $1;
	my $endpath = $2;
	$nodedata = $c->schema->find_node({ node_path =>  $node_path });
	return unless $nodedata;

	$baserole = $c->basetypes->{$nodedata->{basetype_id}}->{role};
	# We'll save the endpath for later, where we'll see if there is a recipe
	return Jet::Node->with_traits($baserole)->new(
		row => $nodedata,
		endpath => $endpath // '',
	);
}

__PACKAGE__->meta->make_immutable;

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
