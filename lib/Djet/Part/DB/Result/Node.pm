package Djet::Part::DB::Result::Node;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::DB::Result::Node

=head1 DESCRIPTION

Common methods for nodes and datanodes.

=head1 METHODS

=head2 has_children

A convenience method; returns true if the current node has children.

=cut

sub has_children {
	my $self = shift;
	return $self->children->count;
}

no Moose::Role;

1;

# COPYRIGHT

__END__
