package Jet::Response;

use 5.010;
use Moose;
use namespace::autoclean;

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
	isa => 'Jet::Schema::ResultSet::DataNode',
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
	lazy => 1,
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
		my $request = $self->request;
		return $request->accept_types->[0];
	},
);

=head2 template

The response template

=cut

has template => (isa => 'Maybe[Str]', is => 'rw' );

=head1 METHODS

=head2 render

Chooses the output renderer based on the requested response types

=cut

sub render {
	my $self = shift;
	$self->template($self->data_nodes->first->basetype->render_template) unless $self->template;
	warn join ' ', 'Rendering', $self->template, 'as', $self->type;
	$self->type =~/(html|json)/i;
	my $type = $1;
	my $renderer = $self->request->renderers->{$type};
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

Copyright 2013 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
