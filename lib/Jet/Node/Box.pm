package Jet::Node::Box;

use 5.010;
use Moose;

use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Node::Box - A box of Nodes

=head1 SYNOPSIS

=head1 ATTRIBUTES

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
	return $nodedata ? Jet::Node->new(row => $nodedata) : undef;
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
