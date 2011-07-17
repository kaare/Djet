package Jet::Node;

use 5.010;
use Moose;

use Jet::Context;

with 'Jet::Role::Log';

## 'domain' for testing purposes

has 'result' => (
	isa => 'Jet::Engine::Result',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		return $self->schema->select($self->basetype);
	},
);
has 'node_id' => (
	isa => 'Int',
	is => 'rw',
);
has 'basetype' => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return $self->node->{base_type};
	},
);

sub add {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';
	for my $column (qw/title part/) {
		return unless defined $args->{$column};
	}

	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $opts = {returning => '*'};
	my $result = $schema->insert($self->basetype, $args, $opts);
	$self->result($result);
	$self->node_id($result->next->get_column('id'));
}

sub add_child {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';

	for my $column (qw/basetype title part/) {
		return unless ($args->{$column});
	}
# XXX TODO Check that basetype is valid
	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $basetype = delete $args->{basetype};
	my $opts = {returning => '*'};
	my $child = $schema->insert($basetype, $args, $opts);
	return $self->new(
		result => $child,
		node_id => $child->next->get_column('id'),
	);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS
