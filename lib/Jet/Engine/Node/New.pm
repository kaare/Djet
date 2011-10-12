package Jet::Engine::Node::New;

use 5.010;
use Moose;

extends 'Jet::Engine';

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Node::New - Add a new node to a parent

=head1 SYNOPSIS

=head1 METHODS

=head2 data

Moves a node to a new parent

=head1 PARAMETERS

=head2 parent_id

Where to find the parent. Default the current parent

=cut

sub data {
	my $self = shift;
	my $parms = $self->parameters;
	my $basetype = $parms->{basetype};
	my $names = $parms->{names};
	return unless $basetype and $names->{title};

	my %data = %$names;
	if ($data{part}) {
		$data{part} = lc $data{part};
		$data{part} =~ s/\s+//g;
	}
	$data{basetype} //= $basetype;
	$self->node->add_child(\%data)
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
