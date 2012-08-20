package Jet::Response;

use 5.010;
use Moose;

with 'Jet::Role::Log';

=head1 NAME

Jet::Response - Response Class for Jet

=head1 DESCRIPTION

This is the Response class for L<Jet>.

=head1 ATTRIBUTES

=head2 renderers

All the rendering engines

=cut

has renderers  => (
	isa => 'HashRef',
	is => 'ro',
);

=head2 status

The response status. Default 200

=cut

has status   => (isa => 'Int', is => 'rw', default => 200);

=head2 headers

The response headers. Default html

=cut

has headers  => (
	isa => 'ArrayRef',
	is => 'rw',
	default => sub {
		[ 'Content-Type' => 'text/html; charset="utf-8"' ]
	},
);

=head2 output

The output content.

=cut

has output   => (
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
	lazy => 1,
	default => sub {
		my $self = shift;
		my $request = $self->stash->{request};
		return $request->accept_types->[0];
	},
);

=head2 stash

The stash

=cut

has 'stash' => (
	isa => 'HashRef',
	is => 'ro',
);

=head2 template

The response template

=cut

has template => (isa => 'Str', is => 'rw' );

=head1 METHODS

=head2 render

Chooses the output renderer based on the requested response types

=cut

sub render {
	my $self = shift;
	warn join ' ', 'Rendering', $self->template, 'as', $self->type;
	$self->type =~/(html|json)/i;
	my $type = $1;
	my $renderer = $self->renderers->{$type};
	my $output = $renderer->render($self->template, $self->stash);
	$self->output([ $output ]);
}

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
