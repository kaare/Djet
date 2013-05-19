package Jet::Engine;

use 5.010;
use Moose;

with qw/Jet::Role::Log/;

=head1 NAME

Jet::Engine - Jet Engine Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engines.

In your engine you just write

extends 'Jet::Engine';

=head1 ATTRIBUTES

=cut

has stash => (
	isa => 'HashRef',
	is => 'ro',
	lazy => 1,
	default => sub { {} },
);
has request => (
	isa => 'Jet::Request',
	is => 'ro',
	handles => [qw/
		basetypes
		cache
		config
		schema
	/],
);
has basenode => (
	isa => 'Jet::Basenode',
	is => 'ro',
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
);

=head2 arguments

This is the set of arguments for this engine

=cut

has 'arguments' => (
	isa => 'HashRef',
	is => 'ro',
);

=head1 METHODS

=head2 init

Engine initialization stuff

=cut

sub init {
	my $self = shift;
	for my $method ($self->_init) {
		$self->$method;
	}
	return 1;
}

=head2 data

Process data

=cut

sub data {
	my $self = shift;
	for my $method ($self->_data) {
		$self->$method;
	}
	return 1;
}

=head2 render

Render data

=cut

sub render {
	my $self = shift;
	for my $method ($self->_data) {
		$self->$method;
	}
	return 1;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

