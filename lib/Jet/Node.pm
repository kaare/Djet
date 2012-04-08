package Jet::Node;

use 5.010;
use Moose;

use Jet::Context;

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 row

The node data found for this node

=head2 endpath

The path found after the node_path

=head2 basetype

The node's basetype

=head2 path

The node's path

=cut

has row => (
	traits    => ['Hash'],
	is        => 'ro',
	isa       => 'HashRef',
	default   => sub { {} },
	handles   => {
		set_column     => 'set',
		get_column     => 'get',
		has_no_columns => 'is_empty',
		num_columns    => 'count',
		delete_column  => 'delete',
		get_columns    => 'kv',
	},
);
has endpath => (
	isa => 'Str',
	is => 'ro',
);
has basetype => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $c = Jet::Context->instance();
		return $c->basetypenames->{$self->get_column('basetype_id') };
	},
);
has path => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return $self->get_column('node_path');
	},
);

=head1 METHODS

=head2 BEGIN

Build the Jet with roles

=cut

BEGIN {
	my $self = shift;
	with 'Jet::Role::Log';
	my $c = Jet::Context->instance;
	my $config = $c->config->options->{'Jet::Node'};
	return unless $config->{role};

	my @roles = ref $config->{role} ? @{ $config->{role} }: ($config->{role});
	with ( map "Jet::Role::$_", @roles ) if @roles;
}

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

=head2 move

Move node to a new parent

=cut

sub move {
	my ($self, $parent_id) = @_;
	return unless $parent_id and $self->row;

	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $opts = {returning => '*'};
	my $success = $schema->move($self->path_id, $parent_id);
}

=head2 add_child

Add a new child node to the current node

=cut

sub add_child {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';

	$args->{parent_id} = $self->get_column('id');
	my $c = Jet::Context->instance();
	$args->{basetype_id} ||= $c->basetypes->{delete $args->{basetype}}{id} if $args->{basetype}; # Try to find basetype_id from basetype if that is defined
	for my $column (qw/basetype_id title/) {
		return unless ($args->{$column});
	}

	my $schema = $c->schema;
	my $basetype = delete $args->{basetype};
	my $opts = {returning => '*'};
	return $self->new(
		row => $schema->insert($args, $opts),
	);
}

=head2 move_child

Move child node here

=cut

sub move_child {
	my ($self, $child_id) = @_;
	return unless $child_id and $self->row;

	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $opts = {returning => '*'};
	my $success = $schema->move($child_id, $self->get_column('id'));
}

=head2 children

Return the children of the current node

=cut

sub children {
	my ($self, %opt) = @_;
	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $base_type = $self->basetype || return;

	my $parent_id = $self->get_column('id');
	$opt{parent_id} = $parent_id;
	$opt{basetype_id} ||= $c->basetypes->{delete $opt{basetype}}{id} if $opt{basetype}; # Try to find basetype_id from basetype if that is defined
	my $result = $schema->search_node(\%opt);
	return [ map {Jet::Node->new(row =>  $_)} @$result ];
}

=head2 parents

Return the parents of the current node

Required parameters:

base_type

=cut

sub parents {
	my ($self, %opt) = @_;
	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $parent_base_type = $opt{base_type} || return;

	my $node_id = $self->get_column('id');
	my $where = {
		base_type => $self->basetype,
		node_id => $node_id,
	};
	my $nodes = $schema->search_nodepath(\%opt);
	my %nodes;
	for my $node (@$nodes) {
		push @{ $nodes{$node->{base_type}} }, $node;
	}
	my @result;
	while (my ($base_type, $nodes) = each %nodes) {
		for my $node (@{ $nodes }) {
			$where = {
				id => $node->{node_id},
			};
			push @result, map {{%$node, %$_}} @{ $schema->search($base_type, $where) };
		}
	}
	return [ map {Jet::Node->new(row => $_)} @result ];
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
