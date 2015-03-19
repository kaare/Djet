package Djet::Part::Generic::Urify;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Generic::Urify

=head1 DESCRIPTION

Installs an urify method

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 domain_node

The first found domain node.

=cut

has 'domain_node' => (
	is => 'ro',
	isa => 'Djet::Schema::Result::Djet::DataNode',
	default => sub {
		my $self = shift;
		my $model = $self->model;
		my $domain_basetype = $model->basetype_by_name('domain');
		return $model->datanode_by_basetype($domain_basetype);
	},
	lazy => 1,
);

=head1 METHODS

=head2 urify

Takes up to three parameters, node, domain node, and path, and returns the full URI path to the node.

	node defaults to the basenode

	domain node defaults to the current domain_node

There are four different ways to call urify:

	$self->urify;					Use the basenode and current domain_node
	$self->urify($node);			Use the specified node and current domain_node
	$self->urify($node, $domain);	Use the specified node and domain node
	$self->urify({node => $node, domain_node => $domain, path => $path});

It works by finding the nearest domain node, use its name as domain name and change the path to the difference between the two node_paths

If the path is given, it can modify the way that urify works.

If it's a Fully Qualified Domain Name, then the path is returned as-is.

If it's an absolute path, then the path is appended to the domain_node's path.

If it's a relative path, it's appended to the node's path

=cut

sub urify {
	my ($self, $node, $domain_node) = @_;

	my $path;
	my $params = $node;
	if (ref $params eq 'HASH') {
		$node = $params->{node};
		$domain_node = $params->{domain_node};
		$path = $params->{path};
	}
	return $path if defined $path and $path =~ m{^\w*://}; # FQDN

	my $model = $self->model;
	$node ||= $model->basenode;
	$domain_node ||= $self->domain_node;
	if (defined $path and $path =~ m{^/\w}) { # Absolute path
		$node = $domain_node;
		$path =~ s|^/||;
	}

	my $domain_name = $domain_node->name;
	my $domain_path = $domain_node->node_path;
	my $node_path = $node->node_path;
	if ($model->config->config->{environment} eq 'live') {
		$node_path =~ s/^$domain_path/$domain_name/;
		$node_path = join '/', $node_path, $path if $path;
		return $node_path ? "//$node_path" : $node_path;
	} else {
		$node_path = join '/', $node_path, $path if $path;
		my $uri = '//' . $model->request->uri->host_port . $node_path;
		return $uri;
	}
}

no Moose::Role;

1;

#COPYRIGHT

