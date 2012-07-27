package Jet::Engine::Part::Stash::Stuff;

use 5.010;
use Moose;

extends 'Jet::Engine::Part';

with 'Jet::Role::Log';

=head1 NAME

Jet::Part::Stash - Stash some stuff

=head1 SYNOPSIS

Put something on the stash

=head1 ATTRIBUTES

=cut

has stashname => (
	is => 'ro',
	isa => 'Str',
);
has method => (
	is => 'ro',
	isa => 'Str',
);
has order => (
	is => 'ro',
	isa => 'Str',

);
has where => (
	is => 'ro',
	isa => 'Str',

);

=head1 METHODS

=head2 run

=cut

sub run {
	my $self = shift;
	my $stashname = $self->stashname;
	my $method = $self->method;
	my $order = $self->order;
	my $where = $self->where;
	if ($method) {
		my $data = $self->engine->schema->$method($where, $order);
		$self->engine->stash->{$stashname} = $data;
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
