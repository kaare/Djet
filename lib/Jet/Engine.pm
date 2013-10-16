package Jet::Engine;

use 5.010;
use Moose;
use namespace::autoclean;

with qw/Jet::Role::Log/;

=head1 NAME

Jet::Engine - Jet Engine Base Class

=head1 DESCRIPTION

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
		log
	/],
);
has basenode => (
	isa => 'Jet::Schema::Result::DataNode',
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

sub _run {
	my ($self, $stage) = @_;
	my $vstage = '_' . $stage;
	for my $method ($self->$vstage) {
		$self->log->debug("Executing method $method in stage $stage");
		$self->$method;
	}
	return 1;
}

=head1 METHODS

=head2 init

Engine initialization stuff

=cut

sub init {
	my $self = shift;
	$self->_run('init');
}

=head2 data

Process data

=cut

sub data {
	my $self = shift;
	$self->_run('data');
}

=head2 render

Render data

=cut

sub render {
	my $self = shift;
	$self->_run('render');
}

__PACKAGE__->meta->make_immutable;

1;

__END__

