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

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

