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

Takes up to two parameters; node, and path, and returns the full URI path to the node.

	node defaults to the basenode

There are three different ways to call urify:

	$self->urify;					Use the basenode
	$self->urify($node);			Use the specified node 
	$self->urify($path);			Use the path

It works by prefixing the path, or node->path with the http_host parameter from the environment.

If it's a Fully Qualified Domain Name, then the path is returned as-is.

If it's an absolute path, then the path is appended to the domain_node's path.

If it's a relative path, it's appended to the node's path

=cut

sub urify {
	my ($self, $param) = @_;
	my ($node, $path);
	if (ref $param) {
		$node = $param;
	} else {
		$path = $param;
	}
	return $path if defined $path and $path =~ m{^\w*://}; # FQDN

	my $model = $self->model;
	$node ||= $model->basenode unless $path;
	if (defined $path and $path =~ m{^/\w}) { # Absolute path
		$path =~ s|^/||;
	}

	my $domain_name = $model->http_host;
	my $node_path = defined $node ? $node->node_path : $path;
	my $uri = join '/', '/', $domain_name, $node_path;
	return $uri;
}

no Moose::Role;

1;

#COPYRIGHT

