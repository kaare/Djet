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
		my $domain_basetype = $self->model->basetype_by_name('domain');
		return $self->datanode_by_basetype($domain_basetype);
	},
	lazy => 1,
);

=head1 METHODS

=head2 urify

Takes a node and a domain node and returns the full URI path to the node.

It works by finding the nearest domain node, use its name as domain name and change the path to the difference between the two node_paths

	node defaults to the basenode

	domain node defaults to the current domain_node

=cut

sub urify {
	my ($self, $node, $domain_node) = @_;
	my $model = $self->model;
	$node ||= $self->basenode;
	$domain_node ||= $self->domain_node;

	my $domain_name = $domain_node->name;
	my $domain_path = $domain_node->node_path;
	my $node_path = $node->node_path;
	if ($model->config->config->{environment} eq 'live') {
		$node_path =~ s/^$domain_path/$domain_name/;
		return $node_path ? "//$node_path" : $node_path;
	} else {
		my $uri = '//' . $self->request->uri->host_port . $node_path;
		$uri = $uri . '/' unless $uri =~ m|/$|;
		return $uri;
	}
}

no Moose::Role;

1;

#COPYRIGHT

