package Jet::Plugin::Filter::Request;

use 5.010;
use Moose;

extends 'Jet::Plugin';

with 'Jet::Role::Log';

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS

=head1 METHODS

=head2 data

Returns 1 if conditions are met

=head1 CONDITIONS

=head2 method

=head2 content_type

=cut

sub data {
	my $self = shift;
	my $c = Jet::Context->instance();
	my $method = $self->in->{method};
	my $content_type = $self->in->{content_type};
	my $req = $c->request;
	return unless $method eq $req->method;
	return unless $req->content_type =~ /$content_type/;

	return 1;
}

no Moose::Role;

1;

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
