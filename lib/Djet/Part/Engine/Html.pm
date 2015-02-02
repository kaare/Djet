package Djet::Part::Engine::Html;

use Moose::Role;
use namespace::autoclean;
use Try::Tiny;

# requires qw/init data return_value/;

=head1 NAME

Djet::Part::Engine::Html - Add functionality to html engines

=head1 METHODS

=head2 BUILD

Tell the machine that we can handle html

=cut

after BUILD => sub {
	my $self = shift;
	$self->add_provided_content_type( { 'text/html' => 'to_html' });
};

=head2 charsets_provided

Return content as UTF-8

=cut

sub charsets_provided { ['utf-8'] }

=head2 default_charset

Return content as UTF-8

=cut

sub default_charset { 'utf-8' }

=head2 to_html

Sets the content type to html, and calls init_data and data (if they're not omitted).

Finally renders the template and returns the result.

=cut

sub to_html {
	my $self = shift;
	$self->view_page;
}

=head2 view_page

View the page

=cut

sub view_page {
	my $self = shift;
	$self->content_type('html');
	my $model = $self->model;
	$self->init_data;
	return $self->return_value if $self->has_return_value;

	$self->data;
	return $self->return_value if $self->has_return_value;

	$self->template($self->render_template) unless $self->_has_template;
	$model->log->debug('Template ' . $self->template);
	my $result;
	try {
		$result = $self->renderer->render($self->template, $self->stash);
	} catch {
		my $e = shift;
		$model->log->error($e);
	};
	return $result;
};

=head2 render_template

Set the template for use when rendering

Use the basetype template name, and if it's not there, find it with $self->template_name

=cut

sub render_template {
	my $self= shift;
	my $basenode = $self->basenode;
	my $template = $basenode->basetype->template;
	$template = $self->template_substitute($template) if defined($template) and $template =~ /<.+>/;
	return $template if $template;

	return $self->template_name($basenode);
}

=head2 template_substitute

Substitute <basetype_name> with the basetype's node_path for the first found node with that basetype - in upwards direction.

If there is a node hanging under some nodes and a domain node with the node_path 'top_level' at the top, 

<domain>/basetype/node.tx would be top_level/basetype/node.tx

=cut

sub template_substitute {
	my ($self, $template) = @_;
	$template =~ /<(.+)>/ or return;

	my $model = $self->model;
	my $basetext = $1;
	my $basetype = $model->basetype_by_name($basetext);
	my $node = $self->datanode_by_basetype($basetype);

	my $node_path = $node->node_path;
	$template =~ s/(.*)<.+>(.*)/$1$node_path$2/ or return;

	return $template;
}

=head2 template_name

Find the template name.

If there is a domain node in the path somewhere, we expect the templates to be placed below
a domain path, so instead of

templates/node/<domain>/index.tx

it is

templates/<domain>/node/index.tx

=cut

sub template_name {
	my ($self, $basenode) = @_;
	my $model = $self->model;
	my $domain_node = $self->stash->{payload}->domain_node;
	my $node_path = $basenode->node_path || 'index';
	my $prefix;
	if ($domain_node) {
		$prefix = $domain_node->node_path;
		$node_path =~ s/^$prefix//;
	}
	$prefix .= '/node';
	$node_path =~ s/\.html$//;
	return $prefix . $node_path . $model->config->config->{template_suffix};
}

no Moose::Role;

1;

# COPYRIGHT

__END__
