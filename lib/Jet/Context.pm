package Jet::Context;

use 5.010;
use MooseX::Singleton;

use CHI;
use Jet::Context::Config;
use Jet::Engine;
use Jet::Response;

with 'Jet::Role::Log';

=head1 NAME

Jet::Context - The Context we work in

=head1 SYNOPSIS

=head1 Attributes

=head2 config

The configuration, as loaded from the configuration files

=head2 schema

Database

=head2 cache

Any cache to be used

=head2 stash

Where data from the flow is stashed

=head2 node

The base node

=head2 response

The response object

=head2 recipe

WIP - provide a recipe for a workflow for a base type

=cut

has config => (
	isa => 'Jet::Context::Config',
	is => 'ro',
	lazy => 1,
	default => sub {
		return Jet::Context::Config->new;
	},
);
has schema => (
	isa => 'Jet::Engine',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		my %connect_info;
		$connect_info{$_} = shift @{ $self->config->{config}{connect_info} } for qw/dbname username password connect_options/;
		return Jet::Engine->new(%connect_info);
	},
);
has cache => (
	isa => 'Object',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		return CHI->new( %{ $self->config->{cache} } );
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
has request => (
	isa => 'Plack::Request',
	is => 'ro',
	writer => '_request',
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
	default => 	sub { {} },
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
	$self->clear_stash;
	$self->clear_recipe;
}

__PACKAGE__->meta->make_immutable;

__END__
