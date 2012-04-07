package Jet::Context;

use 5.010;
use MooseX::Singleton;

use CHI;
use Jet::Context::Config;
use Jet::Context::Rest;
use Jet::Node::Box;
use Jet::Stuff;
use Jet::Response;

with 'Jet::Role::Log';

=head1 NAME

Jet::Context - The Context we work in

=head1 SYNOPSIS

=head1 Attributes

=head2 jet_root

The path to Jet's root directory

=head2 config

The configuration, as loaded from the configuration files

=head2 schema

Database

=head2 cache

Any cache to be used

=head2 stash

Where data from the flow is stashed

=head2 nodebox

The base nodebox

=head2 request

The request

=head2 rest

The rest part of the request

=head2 response

The response object

=head2 recipe

WIP - provide a recipe for a workflow for a base type

=cut

has jet_root => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $path = $INC{'Jet.pm'};
		$path =~ s|lib/+Jet.pm||;
		return $path;
	},
);
has config => (
	isa => 'Jet::Context::Config',
	is => 'ro',
	lazy => 1,
	default => sub {
		return Jet::Context::Config->new;
	},
);
has schema => (
	isa => 'Jet::Stuff',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		my @connect_info = @{ $self->config->jet->{connect_info} };
		my %connect_info;
		$connect_info{$_} = shift @connect_info for qw/dbname username password connect_options/;
		return Jet::Stuff->new(%connect_info);
	},
);
has cache => (
	isa => 'Object',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		return CHI->new( %{ $self->jet->{cache} } );
	},
);
has basetypes => (
	isa       => 'HashRef',
	is        => 'ro',
	clearer   => 'clear_basetypes',
	predicate => 'has_basetypes',
	lazy => 1,
	default => 	sub {
		my $self = shift;
		my $schema = $self->schema;
		return $schema->get_basetypes;
	},
);
has basetypenames => (
	isa   => 'HashRef',
	is    => 'ro',
	lazy  => 1, 
	default => 	sub {
		my $self = shift;
		my $schema = $self->schema;
		my $basetypes = $self->basetypes;
		my $basetypenames;
		$basetypenames->{$basetypes->{$_}{id}} = $basetypes->{$_}{name} for keys %$basetypes;
		return $basetypenames;
	},
);
has request => (
	isa => 'Plack::Request',
	is => 'ro',
	writer => '_request',
);
has rest => (
	isa => 'Jet::Context::Rest',
	is => 'ro',
	lazy => 1,
	clearer   => 'clear_rest',
	predicate => 'has_rest',
	default => sub { Jet::Context::Rest->new },
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
	writer => '_response',
);
has stash => (
	isa       => 'HashRef',
	is        => 'ro',
	clearer => 'clear_stash',
	predicate => 'has_stash',
	lazy => 1,
	default => 	sub {
		my $self = shift;
		return $self->config->{jet}{stash} || {};
	},
);
has nodebox => (
	isa => 'Jet::Node::Box',
	is => 'ro',
	lazy => 1,
	default => sub {Jet::Node::Box->new},
);
has node => (
	isa => 'Jet::Node',
	is => 'rw',
	clearer   => 'clear_node',
	predicate => 'has_node',
);
has recipe => (
	isa       => 'HashRef',
	is        => 'ro',
	clearer   => 'clear_recipe',
	predicate => 'has_recipe',
	lazy => 1,
	default => 	sub {
		my ($self) = @_;
		my $type = $self->node->basetype;
		return $self->basetypes->{$type}{recipe} || {};
	},
);

=head1 METHODS

=head2 clear

Clear request specific attributes

=cut

sub clear {
	my $self = shift;
	$self->_response(Jet::Response->new);
	$self->clear_rest;
	$self->clear_stash;
	$self->clear_node;
	$self->clear_recipe;
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
