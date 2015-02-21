package Djet::Engine;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
use Djet::Mail;

extends 'Web::Machine::Resource';

with 'Djet::Part::Basic';

=head1 NAME

Djet::Engine - Djet Engine Base Class

=head1 DESCRIPTION

Djet::Engine is the basic building block of all Djet Engines.

In your engine you just write

extends 'Djet::Engine';

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
	return $self->model->renderers->{$type};
}

=head2 mailer

Djet mailer

=cut

has mailer => (
	is => 'ro',
	isa => 'Djet::Mail',
	default => sub {
		my $self = shift;
		my $config = $self->model->config->{mail} // {};
		my $renderer = $self->model->renderers->{'html'};
		my $mailer = Djet::Mail->new(
			model => $self->model,
			body => $self->body,
			renderer => $renderer,
		);
		return $mailer;
	},
	lazy => 1,
);

=head1 METHODS

=head2 stash_basic

Put some basic data on the stash

	node = basenode
	nodes = datanodes
	request = request
	domain_node

=cut

sub stash_basic {
	my $self = shift;
	my $model = $self->model;
	my $stash = $self->stash;
	$stash->{basetypes} = $self->basetypes;
	$stash->{payload} = $model->payload_class->new(
		body => $self->body,
		model => $self->model,
		content_type => $self->content_type,
	);
}

=head2 BUILD

Initializes the stash with the payload object,

=cut

sub BUILD {
	my $self = shift;
	$self->stash_basic;
}

=head2 init_data

Init is called just before the original method is called. Add anything that belongs to all media types.

=cut

sub init_data {}

=head2 data

Data is called just after the original method is called. Add anything that belongs to all media types.

=cut

sub data {}

=head2 redirect

Call this if you want to redirect to the already set url

=cut

sub redirect { return \302; }

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

