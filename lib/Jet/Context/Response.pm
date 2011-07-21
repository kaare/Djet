package Jet::Context::Response;

use 5.010;
use Moose;

use Text::Xslate;
use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Context::Response - Response Class for Jet::Context

=head1 DESCRIPTION

This is the Response class for L<Jet::Context>.

=head1 SYNOPSIS


=head1 ATTRIBUTES

=over

=head2 status

=head2 headers

=head2 output

=cut

has status  => (isa => 'Int', is => 'rw', default => 200);
has headers => (isa => 'ArrayRef', is => 'rw', default => sub { [ 'Content-Type' => 'text/html; charset="utf-8"' ] });
has output  => (isa => 'ArrayRef', is => 'rw', default => sub { [ 'Jet version 0.0000001' ]} );

=head1 METHODS

=over

=head2 render

Chooses the output renderer based on the requested response types

=cut

sub render {
	my $self = shift;
	$self->render_html; # XXX We can only do html for now
}

=head2 render_html

=cut

sub render_html {
	my $self = shift;
	my $c = Jet::Context->instance;
	my  $tx = Text::Xslate->new();
	my $node = $c->node;
	my $template = $c->config->{template_path} . $node->base_type . $c->config->{template_suffix};
	$tx->render($template, $c->stash);
}

__PACKAGE__->meta->make_immutable;

__END__
