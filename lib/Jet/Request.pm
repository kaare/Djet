package Jet::Request;

use 5.010;
use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use HTTP::Headers::Util qw(split_header_words);
use Plack::Request;

with 'Jet::Role::Log';

=head1 NAME

Jet::Request - The Jet Request

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 env

The web environment

=cut

has env => (
	is => 'ro',
	isa => 'HashRef',
);

=head2 request

The plack request

=cut

has request => (
	is => 'ro',
	isa => 'Plack::Request',
	default => sub {
		my $self = shift;
		return Plack::Request->new($self->env);
	},
	lazy => 1,
);

=head2 schema

The Jet schema

=cut

has schema => (
	is => 'ro',
	isa => 'Jet::Schema',
	handles => [qw/
		basetypes
		config
	/],
);

=head2 accept_types

Arrayref of types the client will accept.

=cut

has accept_types => (
	isa => 'ArrayRef',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $request = $self->request;
		my $headers = $request->headers;
		my %types;

		# We use the content type in the HTTP Request as a backup default.
		$types{ $request->content_type } = .001 if $request->content_type;

		if ($request->method eq "GET" && $request->param('content-type')) {
			$types{ $request->param('content-type') } = .002;
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

=head2 verb

The verb, or method

=cut

has verb => (
	isa => 'Str',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $request = $self->request;
		# Methods PUT, DELETE can be tunnelled through POST
		# XXX For safer handling, add tests for POST method and PUT, DELETE value
		return $request->param('_method') || $request->method || 'GET';
	},
);

=head2 serializer

The (de)serializer if the requestis a "REST" call

=cut

has serializer => (
	isa => 'Data::Serializer',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return unless $self->request->content_type;

		return Data::Serializer->new(
			serializer => $self->request->content_type,
		);
	},
);

=head2 rest_parameters

If the request is a "REST" call, the parameters will be here

=cut

has rest_parameters => (
	isa => 'Hash::MultiValue',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $result;
		try {
			$result = $self->request->type eq 'HTML' ?
				$self->request->parameters :
				Hash::MultiValue->new(%{ $self->serializer->raw_deserialize($self->content) });
		} catch {
			warn "Couldn't serialize data with " . $self->content_type;
		};
		return $result;
	},
);

=head1 METHODS

=cut

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
