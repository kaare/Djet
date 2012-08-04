package Jet::Engine::Part::Stash::Basetype;

use 5.010;
use Moose;

extends 'Jet::Engine::Part';

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Part::Stash::Basetype - Stash basetypes

=head1 SYNOPSIS

Put basetypes on the stash

=head1 ATTRIBUTES

=cut

has stashname => (
	is => 'ro',
	isa => 'Str',
);
has key => (
	is => 'ro',
	isa => 'Str',
);
has value => (
	is => 'ro',
	isa => 'Str|ArrayRef[Str]',

);

=head1 METHODS

=head2 run

=cut

sub run {
	my $self = shift;
	my $stashname = $self->stashname || 'basetype';
	my $key = $self->key;
	my $value = $self->value;
	my $args;
	$args->{$key} = $value if $key;
	my $data = $self->engine->schema->find_basetype($args);
debug($data, $args);
	$self->engine->stash->{$stashname} = $data;
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
