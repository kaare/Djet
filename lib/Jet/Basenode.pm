package Jet::Basenode;

use 5.010;
use Moose;

with 'MooseX::Traits';

extends 'Jet::Node';

=head1 NAME

Jet::Basenode - The Base Jet Node

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 schema

=head2 basetypes

=head2 row

The node data found for this node

=head2 arguments

The path found after the node_path

=head2 basetype

The node's basetype

=cut

has arguments => (
	isa => 'ArrayRef[Str]',
	is => 'ro',
);

=head1 METHODS

=head2 BEGIN

Build the Jet with roles

=cut

# BEGIN {
	# # Logging
	# with 'Jet::Role::Log';
	# # Configuration
	# my $config = Jet->config->options->{'Jet::Basenode'};
	# return unless $config->{role};

	# my @roles = ref $config->{role} ? @{ $config->{role} }: ($config->{role});
	# with ( map "Jet::Role::$_", @roles ) if @roles;
# }

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
