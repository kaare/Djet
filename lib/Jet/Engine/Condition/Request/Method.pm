package Jet::Engine::Condition::Request::Method;

use 5.010;
use Moose;

extends 'Jet::Engine::Condition';

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Condition::Request::Method - Request Method Condition

=head1 SYNOPSIS

Return true if method condition is met

=head1 ATTRIBUTES

=head2 request_method

HTTP Method, Can be one or more of GET,POST,PUT,DELETE

=cut

has requestmethod => (
	is => 'ro',
	isa => 'ArrayRef'
);

=head1 METHODS

=head2 condition

=cut

sub condition {
	my $self = shift;
	my $method = $self->requestmethod;
	return $self->request->method =~ $method;
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
