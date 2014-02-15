package Jet::Response;

use 5.010;
use Moose;
use namespace::autoclean;

use HTTP::Throwable::Factory qw/http_throw/;

with 'Jet::Role::Log';

=head1 NAME

Jet::Response - Response Class for Jet

=head1 DESCRIPTION

This is the Response class for L<Jet>.

=head1 ATTRIBUTES

=head2 stash

The stash

=cut

has 'stash' => (
	isa => 'HashRef',
	is => 'ro',
);

=head2 request

The Jet::Request

=cut

has request  => (
	isa => 'Jet::Request',
	is => 'ro',
);

=head2 data_nodes

The node "stack"

=cut

has data_nodes  => (
	isa => 'Jet::Schema::ResultSet::Jet::DataNode',
	is => 'ro',
);

=head2 basenode

The node we're looking at

=cut

has basenode => (
	isa => 'Jet::Schema::Result::Jet::DataNode',
	is => 'ro',
);

=head2 status

The response status. Default 200

=cut

has status => (isa => 'Int', is => 'rw', default => 200);

=head2 headers

The response headers. Default html

=cut

has headers  => (
	isa => 'ArrayRef',
	is => 'rw',
	default => sub {
		my $self = shift;
		return $self->type =~ /json/i ?
			[ 'Content-Type' => 'application/json' ] :
			[ 'Content-Type' => 'text/html; charset="iso-8859-1"' ];
	},
	lazy => 1,
);

=head2 output

The output content.

=cut

has output	=> (
	isa => 'ArrayRef',
	is => 'rw',
	predicate => 'has_output',
);

=head2 type

Default response type is no 1 from accept_types list

Changable, but should be only one of the accepted types

=cut

has type => (
	isa => 'Str',
	is => 'ro',
	writer => 'set_type',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $request = $self->request;
		return $request->accept_types->[0];
	},
);

=head2 renderer

The class that does the actual rendering

=cut

has renderer => (
	isa => 'Object',
	is => 'ro',
	writer => 'set_renderer',
	predicate => '_has_renderer',
);

=head2 template

The response template

=cut

has template => (
	isa => 'Maybe[Str]',
	is => 'rw',
	predicate => '_has_template',
);

=head1 METHODS

=head2 render

Chooses the output renderer based on the requested response types

=cut

sub render {
	my $self = shift;
	my $request = $self->request;
	$request->log->info(join ' ', 'Rendering', $self->template, 'as', $self->type);
	$request->log->debug('Stashed items: ' . join ', ', keys %{ $self->stash });
	my $output = $self->renderer->render($self->template, $self->stash);
	$self->output([ $output ]);
}

=head2 redirect

Throw a 302 HTTP::Exception

=cut

sub redirect {
	my ($self, $url) = @_;
	http_throw(Found => { location => $url });
}

=head2 uri_for

Takes a path and returns the full URI path to the resource.

=cut

sub uri_for {
	my ($self, $path) = @_;
	my $uri = $self->request->request->base;
	$uri->path($path);
	return $uri->as_string;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
