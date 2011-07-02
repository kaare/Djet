package Jet::Node;

use 5.010;
use Moose;

use Jet::Context;

## 'domain' for testing purposes

has 'data' => (
	isa => 'HashRef',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $viewname = 'data.' . $self->basetype . '_view';
		my $q = qq{
			SELECT * FFROM
				$viewname
			WHERE
				id = ?
		};
		return $self->data($self->schema->single(sql => $q, data => [$self->node_id]));
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
	my %args = %{ $args };
delete $args{basetype};
# $args{parent_id} = undef;
	my $viewname = 'data.' . $self->basetype . '_view';
	my $names = join ',', keys %args;
	my $values = [ values %args ];
	my $placeholders = join ',', ('?') x keys %args;
	my $q = qq{
		INSERT INTO
			$viewname ($names)
		VALUES
			($placeholders)
	};
	$self->data($schema->insert(sql => $q, data => $values));
	$self->node_id($self->data->{id});
}

sub add_child {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';
	for my $column (qw/basetype title part/) {
		return unless ($args->{$column});
	}
# XXX Check that basetype is valid

	my $c = Jet::Context->instance();
	my $schema = $c->schema;

	my %args = %{ $args };
	$args{parent_id} = $self->node_id;
	my $viewname = 'data.' . delete($args{basetype}) . '_view';
	my $names = join ',', keys %args;
	my $values = [ values %args ];
	my $placeholders = join ',', ('?') x keys %args;
	my $q = qq{
		INSERT INTO
			$viewname ($names)
		VALUES
			($placeholders)
	};
	$schema->insert(sql => $q, data => $values);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS
