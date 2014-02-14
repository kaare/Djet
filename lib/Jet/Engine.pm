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

=head2 stash

=cut

has stash => (
	isa => 'HashRef',
	traits => ['Hash'],
	is => 'ro',
	lazy => 1,
	default => sub { {} },
	handles => {
		set_stash => 'set',
		clear_stash => 'clear',
	},
);

=head2 request

=cut

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

=head2 basenode

=cut

has basenode => (
	isa => 'Jet::Schema::Result::Jet::DataNode',
	is => 'ro',
);

=head2 response

=cut

has response => (
	isa => 'Jet::Response',
	is => 'ro',
);

=head1 METHODS

=head2 init

Engine initialization stuff

=cut

sub init { }

=head2 data

Process data

=cut

sub data { }

=head2 set_renderer

Choose the renderer

=cut

sub set_renderer {
	my $self = shift;
	my $response = $self->response;
	return if $response->_has_renderer;

	my $type = $response->type =~/(html|json)/i ? $1 : 'html';
	$response->set_renderer($self->request->renderers->{$type})
}

=head2 render

Render data

=cut

sub render {
	my $self = shift;
	my $response = $self->response;
	my $basenode = $response->basenode;
	$response->template($basenode->render_template) unless $response->_has_template;
	$response->render;
}

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__

