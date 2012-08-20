package Jet::Engine::Part;

use 5.010;
use Moose;

with qw/Jet::Role::Log Jet::Role::Engine::Part/;

=head1 NAME

Jet::Engine::Part - Jet Engine Part Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engine parts.

In your engine you just write

extends 'Jet::Engine::Part';

=head1 ATTRIBUTES

=cut

has template => (
	isa => 'Str',
	is => 'ro',
	predicate => 'has_template',
);

=head1 METHODS

=head2 title

Provides the human readable title

=cut

sub title {
	return 'Not Yet Implemented'; 
}

sub init {}
sub run {}
sub render {
	my $self = shift;
	return unless $self->has_template;

	my $response = $self->response;
	$response->type =~/(html|json)/i;
	my $type = $1;
	my $renderer = $response->renderers->{$type};
	my $output = $renderer->render($self->template, $self->stash);
	$self->stash->{$self->stashname} = $output;

}

__PACKAGE__->meta->make_immutable;

1;
__END__

