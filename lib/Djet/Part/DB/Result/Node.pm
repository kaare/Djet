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

=head2 node_owner

Return a result row with the owner.

=cut

sub node_owner {
	my $self = shift;
	my $user_type = $self->result_source->schema->resultset('Djet::Basetype')->find({name => 'user'}) or return;

	return $user_type->find_related('datanodes', {part => $self->node_modified_by});
}

=head2 data_owner

Return a result row with the owner.

=cut

sub data_owner {
	my $self = shift;
	my $user_type = $self->result_source->schema->resultset('Djet::Basetype')->find({name => 'user'}) or return;

	return $user_type->find_related('datanodes', {part => $self->data_modified_by});
}

no Moose::Role;

1;

# COPYRIGHT

__END__
