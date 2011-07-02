package Jet::Node;

use 5.010;
use Moose;

use Jet::Context;

## 'domain' for testing purposes

has 'data' => (
	isa => 'HashRef',
	is => 'ro',
);

has 'node_id' => (
	isa => 'Int',
	is => 'ro',
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
say STDERR "1", ref $args;
	return unless ref $args eq 'HASH';
say STDERR "2";
	for my $column (qw/title part/) {
		return unless defined $args->{$column};
	}
say STDERR "3";

	my $c = Jet::Context->instance();
	my $schema = $c->schema;
say STDERR "4";

	my %args = %{ $args };
delete $args{basetype};
$args{parent_id} = undef;
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
use Data::Dumper;
print STDERR Dumper $q, $values;
	$schema->insert(sql => $q, data => $values);
}

sub add_child {
	my ($self, $args) = @_;
say STDERR "1", ref $args;
	return unless ref $args eq 'HASH';
say STDERR "2";
	for my $column (qw/basetype title part/) {
		return unless ($args->{$column});
	}
## Check that basetype is valid
say STDERR "3";

	my $c = Jet::Context->instance();
	my $schema = $c->schema;
say STDERR "4";

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
use Data::Dumper;
print STDERR Dumper $q, $values;
	$schema->insert(sql => $q, data => $values);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS
