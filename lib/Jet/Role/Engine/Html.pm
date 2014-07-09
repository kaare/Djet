package Jet::Role::Engine::Html;

use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Engine::Html - Add functionality to html engines

requires qw/init data omit_run/;

=head1 METHODS

=head2 BUILD

Tell the machine that we can handle html

=cut

after BUILD => sub {
	my $self = shift;
	$self->add_provided_content_type( { 'text/html' => 'to_html' });
};

=head2 to_html

Sets the content type to html, initializes the stash with node, nodes and request,
and calls init_data and data (if they're not omitted).

Finally renders the template and returns the result.

=cut

sub to_html {
	my $self = shift;
	$self->content_type('html');

	my $stash = $self->stash;
	$stash->{node} = $self->basenode;
	$stash->{nodes} = $self->datanodes;
	$stash->{request} = $self->request;

	$self->init_data unless $self->omit_run->{init_data};
	$self->data unless $self->omit_run->{data};

	$self->template($self->basenode->render_template) unless $self->_has_template;

	my $schema = $self->schema;
	$schema->log->debug('Template ' . $self->template);
	return $self->renderer->render($self->template, $self->stash);
};

no Moose::Role;

1;

# COPYRIGHT

__END__
