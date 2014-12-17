package Djet::Part::DB::Result::Node;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::DB::Result::Node

=head1 DESCRIPTION

Common methods for nodes and datanodes.

=head1 METHODS

=head2 add

Add a new node

=cut

sub add {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';
	for my $column (qw/title part/) {
		return unless defined $args->{$column};
	}

	my $opts = {returning => '*'};
	my $row = $self->schema->insert($self->basetype, $args, $opts);
	$self->_row($self->schema->row($row, $self->basetype));
}

=head2 move

Move node to a new parent

=cut

sub move {
	my ($self, $parent_id) = @_;
	return unless $parent_id and $self->row;

	my $opts = {returning => '*'};
	my $success = $self->schema->move($self->path_id, $parent_id);
}

=head2 add_child

Add a new child node to the current node

=cut

sub add_child {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';

	$args->{parent_id} = $self->get_column('id');
	$args->{basetype_id} ||= $self->basetypes->{delete $args->{basetype}}{id} if $args->{basetype}; # Try to find basetype_id from basetype if that is defined
	for my $column (qw/basetype_id title/) {
		return unless ($args->{$column});
	}

	my $basetype = delete $args->{basetype};
	my $opts = {returning => '*'};
	return $self->new(
		row => $self->schema->insert($args, $opts),
	);
}

=head2 move_child

Move child node here

=cut

sub move_child {
	my ($self, $child_id) = @_;
	return unless $child_id and $self->row;

	my $opts = {returning => '*'};
	my $success = $self->schema->move($child_id, $self->get_column('id'));
}

=head2 ancestors

Return the ancestors of the current node

Uses the parent method to utilize either the stash or the database

=cut

sub ancestors {
	my ($self) = @_;
	my $stash = $self->stash;

	my $node = $self;
	my @parents;
	while ($node->row->{parent_id}) {
		$node = $node->parent;
		push @parents, $node;
	}
	return [ reverse @parents ];
}

=head2 parents

Return the parents of the current node

A node can have several parents, and we know only one from the path, so this method always requires
a roundtrip to the database

Required parameters:

base_type

=cut

sub parents {
	my ($self, %opt) = @_;
	my $parent_base_type = $opt{base_type} || return;

	my $node_id = $self->get_column('id');
	my $where = {
		base_type => $self->basetype,
		node_id => $node_id,
	};
	my $nodes = $self->schema->search_nodepath(\%opt);
	my %nodes;
	for my $node (@$nodes) {
		push @{ $nodes{$node->{base_type}} }, $node;
	}
	my @result;
	my $schema = $self->schema;
	while (my ($base_type, $nodes) = each %nodes) {
		for my $node (@{ $nodes }) {
			$where = {
				id => $node->{node_id},
			};
			push @result, map {{%$node, %$_}} @{ $schema->search($base_type, $where) };
		}
	}
	return [ map {Djet::Node->new(row => $_)} @result ];
}

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
