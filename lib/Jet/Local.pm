package Jet::Local;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

with 'Jet::Role::Basic';

=head1 NAME

Jet::Local

=head1 DESCRIPTION

Jet::Local is a base class for local_class.

The purpose of this is to have a class that is put on the stash and that can contain
anything you'd like.

=head1 ATTRIBUTES

=head2 domain_node

The first found domain node.

=cut

has 'domain_node' => (
	is => 'ro',
	isa => 'Jet::Schema::Result::Jet::DataNode',
	default => sub {
		my $self = shift;
		my $domain_basetype = $self->schema->basetype_by_name('domain');
		return $self->datanode_by_basetype($domain_basetype);
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
	my $schema = $self->schema;
	$node ||= $self->basenode;
	$domain_node ||= $self->domain_node;

	my $domain_name = $domain_node->name;
	my $domain_path = $domain_node->node_path;
	my $node_path = $node->node_path;
	return $node_path unless $schema->config->config->{environment} eq 'live';

	$node_path =~ s/^$domain_path/$domain_name/;
	return $node_path ? "//$node_path" : $node_path;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

