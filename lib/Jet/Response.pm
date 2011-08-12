package Jet::Response;

use 5.010;
use Moose;

use Text::Xslate;
use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Response - Response Class for Jet::Context

=head1 DESCRIPTION

This is the Response class for L<Jet::Context>.

=head1 SYNOPSIS


=head1 ATTRIBUTES

=over

=head2 status

=head2 headers

=head2 output

=head2 tx

=cut

has status  => (isa => 'Int', is => 'rw', default => 200);
has headers => (isa => 'ArrayRef', is => 'rw', default => sub { [ 'Content-Type' => 'text/html; charset="utf-8"' ] });
has output  => (isa => 'ArrayRef', is => 'rw', default => sub { [ 'Jet version 0.0000001' ]} );
has tx      => (isa => 'Text::Xslate', is => 'ro', lazy => 1, default => sub {Text::Xslate->new() });

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
	my $row = $c->node->row;

	my $node = $c->node;
	my $recipe = $c->recipe;
# XXX
	my $template_name = $c->node->endpath ?
		$recipe->{html_templates}{$c->node->endpath} :
		$recipe->{html_template};
	$template_name ||= $row->get_column('base_type');
	my $template = $c->config->{config}{template_path} . $template_name . $c->config->{config}{template_suffix};
	$c->stash->{node} = $c->node;
	my $output = $self->tx->render($template, $c->stash);
	$self->output([ $output ]);
}

__PACKAGE__->meta->make_immutable;

__END__
