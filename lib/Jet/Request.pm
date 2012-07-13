package Jet::Request;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
use HTTP::Headers::Util qw(split_header_words);

extends 'Plack::Request';

with 'Jet::Role::Log';

=head1 NAME

Jet::Request - The Jet Request

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 accept_types

Arrayref of types the client will accept.

=head2 verb

The verb, or method

=head2 serializer

The (de)serializer if the requestis a "REST" call

=head2 rest_parameters

If the request is a "REST" call, the parameters will be here

=cut

has accept_types => (
	isa => 'ArrayRef',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $headers = $self->headers;
		my %types;

		# We use the content type in the HTTP Request as a backup default.
		$types{ $self->content_type } = .001 if $self->content_type;

		if ($self->method eq "GET" && $self->param('content-type')) {
			$types{ $self->param('content-type') } = .002;
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
has verb => (
	isa => 'Str',
	is => 'ro',
	default => sub {
		my $self = shift;
		# Methods PUT, DELETE can be tunnelled through POST
		# XXX For safer handling, add tests for POST method and PUT, DELETE value
		return $self->param('_method') || $self->method || 'GET';
	},
);
has serializer => (
	isa => 'Data::Serializer',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return unless $self->content_type;

		return Data::Serializer->new(
			serializer => $self->content_type,
		);
	},
);
has rest_parameters => (
	isa => 'Hash::MultiValue',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $result;
		try {
			$result = $self->type eq 'HTML' ?
				$self->parameters :
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
