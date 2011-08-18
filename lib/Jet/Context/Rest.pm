package Jet::Context::Rest;

use 5.010;
use Moose;
use Data::Serializer;
use Try::Tiny;

use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Context::Rest - Resting in the Jet

=head1 SYNOPSIS

=head1 Attributes

=head2 accept_types

(arrayref)

=head2 type

Default no 1 from accept_types list

Changable, but should be only one of the accepted types

=head2 content

if there's something to deserialize

=cut

has accept_types => (
	isa => 'ArrayRef',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
# $c
# $c->request->headers
		return
	},
);
has type => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
return 'JSON'; # XXX shortcircuiting until accept_types is in place
		return $self->accept_types->[0]; # XXX Must be Data::Serializer types
	},
);
has serializer => (
	isa => 'Data::Serializer',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return unless my $type = $self->type;

		return Data::Serializer->new(
			serializer => $type,
		);
	},
);
has content => (
#	isa => 'Str', # XXX Can we have a constraint?
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return unless $self->serializer;

		my $c = Jet::Context->instance;
		my $content = $c->request->content;
		my $result;
		try {
			$result = $self->serializer->raw_deserialize($content)
		} catch {
			warn "Couldn't serialize data with " . $self->type;
		};
		return $result;
	},
);

__PACKAGE__->meta->make_immutable;
1;
