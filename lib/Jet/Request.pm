package Jet::Request;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

extends 'Plack::Request';

with 'Jet::Role::Log';

=head1 NAME

Jet::Request - The Jet Request

=head1 SYNOPSIS

=head1 Attributes

=head2 rest_parameters

If the request is a "REST" call, the parameters will be here

!WIP!

=cut

has rest => (
	isa => 'Jet::Context::Rest',
	is => 'ro',
	lazy => 1,
	clearer   => 'clear_rest',
	predicate => 'has_rest',
	default => sub { Jet::Context::Rest->new },
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
