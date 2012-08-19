package Jet::Engine::Condition::Response::Type;

use 5.010;
use Moose;

extends 'Jet::Engine::Condition';

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Condition::Response::Type - Response Type Condition

=head1 SYNOPSIS

Return true if response type condition will be met

=head1 ATTRIBUTES

=head2 response_type

Response type

=cut

has response_type => (
	is => 'ro',
	isa => 'ArrayRef'
);

=head1 METHODS

=head2 condition

True if one of the accepted types matches the response type

=cut

sub condition {
	my $self = shift;
	my $response_type = $self->response->type;
	my $types = $self->response_type;
	for my $type (@$types) {
		return 1 if $response_type =~ $type;
	}

	return;
}

no Moose::Role;

1;

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may
have available.
