package Jet::Node;

use 5.010;
use Moose;

use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS

=head1 ATTRIBUTES

=cut

has row => (
	isa => 'Jet::Engine::Row',
	is => 'ro',
	writer => '_row',
);
has basetype => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return $self->row->get_columns('base_type');
	},
);

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

	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $opts = {returning => '*'};
	my $row = $schema->insert($self->basetype, $args, $opts);
	$self->_row($schema->row($row, $self->basetype));
}

=head2 add_child

Add a new child node to the current node

=cut

sub add_child {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';

	for my $column (qw/basetype title part/) {
		return unless ($args->{$column});
	}
	$args->{parent_id} = $self->row->get_column('id');
# XXX TODO Check that basetype is valid
	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $basetype = delete $args->{basetype};
	my $opts = {returning => '*'};
	my $child = $schema->insert($basetype, $args, $opts);
	return $self->new(
		row => $schema->row($child, $basetype),
	);
}

=head2 children

Return the children of the current node

=cut

sub children {
	my ($self, $relation_name, $opt) = @_;
	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $base_type = $self->basetype || return;

	my $where = {
		parent_id => $self->row->get_column('id'),
	};
	my $nodes = $schema->search_nodepath($base_type, $where);
	my %nodes;
	for my $node (@$nodes) {
		push @{ $nodes{$node->{base_type}} }, $node;
	}
	my @result;
	while (my ($base_type, $nodes) = each %nodes) {
		for my $node (@{ $nodes }) {
			push @result, @{ $schema->search($base_type, $where) };
		}
	}
	return $schema->result(\@result);

# Split in relations (base_type)
# For hver relation, find id'er
# For hver relation
# SELECT * FROM data.$relation
# WHERE id IN @ids

# stitch et resultobjekt sammen
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
