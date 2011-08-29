package Jet::Context::Rest;

use 5.010;
use Moose;
use Data::Serializer;
use Try::Tiny;
use HTTP::Headers::Util qw(split_header_words);

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
		my $c = Jet::Context->instance;
		my $request = $c->request;
		my $headers = $request->headers;
		my %types;

		# First, we use the content type in the HTTP Request.  It wins all.
		$types{ $request->content_type } = 3 if $request->content_type;

		if ($request->method eq "GET" && $request->param('content-type')) {
			$types{ $request->param('content-type') } = 2;
		}
		if (my $accept_header = $headers->header('accept')) {
	#        $self->accept_only(1) unless keys %types;
			my $counter       = 0;

			foreach my $pair ( split_header_words($accept_header) ) {
				my ( $type, $qvalue ) = @{$pair}[ 0, 3 ];
				next if $types{$type};

				# cope with invalid (missing required q parameter) header like:
				# application/json; charset="utf-8"
				# http://tools.ietf.org/html/rfc2616#section-14.1
				unless ( defined $pair->[2] && lc $pair->[2] eq 'q' ) {
					$qvalue = undef;
				}

				unless ( defined $qvalue ) {
					$qvalue = 1 - ( ++$counter / 1000 );
				}
				$types{$type} = sprintf( '%.3f', $qvalue );
			}
		}
		return [ sort { $types{$b} <=> $types{$a} } keys %types ];
	},
);
has type => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $accept_type = $self->accept_types->[0];
		my @accept_list = (qw/HTML JSON/); # Might be enum?
		for my $ac (@accept_list) {
			return $ac if $accept_type =~ m/$ac/i;
		}
		return $accept_list[0]; # fallback
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
