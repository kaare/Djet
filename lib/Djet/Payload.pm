package Djet::Payload;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

with 'Djet::Part::Basic';

=head1 NAME

Djet::Payload

=head1 DESCRIPTION

Djet::Payload is a base class for payload_class.

The purpose of this is to have a class that is put on the stash and that can contain
anything you'd like.

A good idea is to have lazy attributes which will only be used if necessary.

=head1 ATTRIBUTES

See L<Djet::Part::Basic> for the basic attributes

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

=head2 query_parameters

The query parameters, less the page stuff

=cut

has 'query_parameters' => (
	is => 'ro',
	isa => 'Hash::MultiValue',
	default => sub {
		my $self = shift;
		my $query_parameters = $self->request->query_parameters;
		delete $query_parameters->{page};
		return $query_parameters;
	},
	lazy => 1,
);

=head2 flash

The flash data from the session

=cut

has 'flash' => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		my $token = $self->request->param('flash') || return {};

		return delete $self->session->{flash}{$token} // {};
	},
	lazy => 1,
);

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

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

