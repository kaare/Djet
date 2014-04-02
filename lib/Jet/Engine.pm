package Jet::Engine;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

extends 'Web::Machine::Resource';

=head1 NAME

Jet::Engine - Jet Engine Base Class

=head1 DESCRIPTION

Jet::Engine is the basic building block of all Jet Engines.

In your engine you just write

extends 'Jet::Engine';

=head1 ACCESSORS

Accessors inherited from Web::Machine

=head2 request

The plack request

=head2 response

Web::Machine's response accessor

=head1 ATTRIBUTES

=head2 schema

The Jet schema. For easy access, it also contains the config, basetypes, renderers and log

=cut

has schema => (
	is => 'ro',
	isa => 'Jet::Schema',
	handles => [qw/
		config
		basetypes
		renderers
		log
	/],
);

=head2 body

The Jet body. Contains the stash and basenode

=cut

has body => (
	is => 'ro',
	isa => 'Jet::Body',
	handles => [qw/
		stash
		basenode
		datanodes
	/],
);

has content_types_provided => (
	is => 'ro',
	isa => 'ArrayRef',
	traits => [qw/Array/],
	handles => {
		add_content_type => 'push',
	},
);

=head2 template

The template to be used for rendering

=cut

has 'template' => (
	is => 'rw',
	isa => 'Str',
	predicate => '_has_template',
);

=head2 content_type

The chosen content_type.

Currently it's either html or json.

=cut

has content_type => (
	isa => 'Str',
	is => 'rw',
	predicate => '_has_content_type',
);

=head2 renderer

The thing that will render the output

=cut

has renderer => (
	isa => 'Object',
	is => 'ro',
	lazy_build => 1,
);

sub _build_renderer {
	my $self = shift;
	return unless $self->_has_content_type;

	my $type = $self->content_type =~/(html|json)/i ? $1 : 'html';
	return $self->schema->renderers->{$type};
}

=head1 METHODS

=head2 BUILD

Necessary for the roles

=cut

sub BUILD {}

=head2 init

Init is called just before the original method is called. Add anything that belongs to all media types.

=cut

sub init_data {}

=head2 data

Data is called just after the original method is called. Add anything that belongs to all media types.

=cut

sub data {}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

