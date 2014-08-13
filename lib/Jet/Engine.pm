package Jet::Engine;

use 5.010;
use List::Util qw/first/;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

extends 'Web::Machine::Resource';

with 'Jet::Role::Basic';

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

=head2 content_types_provided

The provided content types

=cut

has content_types_provided => (
	is => 'ro',
	isa => 'ArrayRef',
	traits => [qw/Array/],
	handles => {
		add_provided_content_type => 'push',
	},
);

=head2 content_types_accepted

The accepted content types

=cut

has content_types_accepted => (
	is => 'ro',
	isa => 'ArrayRef',
	traits => [qw/Array/],
	handles => {
		add_accepted_content_type => 'push',
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

=head2 urify

Takes a node_path and returns the full URI path to the resource.

It works by finding the nearest domain node, use its name as domain name and change the path to the difference between the two node_paths

=cut

sub urify {
	my ($self, $path) = @_;
	my $uri = $self->request->request->base;
	$uri->path($path);
	return $uri->as_string;
}

=head2 datanode_by_basetype

Returns the first node from the datanodes, given a basetype or a basetype id

=cut

sub datanode_by_basetype {
	my ($self, $basetype) = @_;
	my $basetype_id = ref $basetype ? $basetype->id : $basetype;
	return first {$_->basetype_id == $basetype_id} @ { $self->datanodes };
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

