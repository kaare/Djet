package Jet::Engine::Part::Stash;

use 5.010;
use Moose;

extends 'Jet::Engine';

with 'Jet::Role::Log';

=head1 NAME

Jet::Part::Stash - Stash something

=head1 SYNOPSIS

Put something on the stash

=head1 METHODS

=head2 data

=cut

sub data {
	my $self = shift;
	my $parms = $self->parameters;
	my $node_name = $parms->{nodes} || 'node';
	my $method = $parms->{method};
	my $where = $parms->{where};
	my $order = $parms->{order};
	my $name = $parms->{stashname};
	if ($method) {
		my $data = $self->schema->$method($where, $order);
		$self->stash->{$name} = $data;
	}
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
