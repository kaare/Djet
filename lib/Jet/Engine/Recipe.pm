package Jet::Engine::Recipe;

use 5.010;
use Moose;

use Jet::JSON;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Recipe - Jet Engine Recipe Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engine recipes.

In your engine you just write

extends 'Jet::Engine::Recipe';

=head1 ATTRIBUTES

=head3 json

For (de)serializing data

=head3 raw

The recipe in raw (serialized) form

=head3 node_role

The role for all nodes of this basetype

=cut

has json => (
	isa => 'Jet::JSON',
	is => 'ro',
	default => sub {
		Jet::JSON->new();
	},
	lazy => 1,
);
has raw => (
	is => 'ro',
	isa => 'Maybe[Str]',
);
has recipe => (
	traits  => ['Array'],
	isa     => 'ArrayRef[HashRef]',
	is => 'ro',
	default => sub {
		my $self = shift;
		$self->raw ? $self->json->decode($self->raw) : [];
	},
	lazy => 1,
	handles => {
		all_engines    => 'elements',
		add_engine     => 'push',
		map_engines    => 'map',
		filter_engines => 'grep',
		find_engine    => 'first',
		get_engine     => 'get',
		join_engines   => 'join',
		count_engines  => 'count',
		has_engines    => 'count',
		has_no_engines => 'is_empty',
		sorted_engines => 'sort',
	},
);

=head1 METHODS

=head2 add_raw_engine

Add engine from raw (serialized) data

=cut

sub add_raw_engine {
	my ($self, $name, $recipe) = @_;
	return unless $recipe;

	$self->add_engine({$name => $self->json->decode($recipe)});
}

=head2 components

Return all components from the recipe as a arrayref

=cut

sub components {
	my $self = shift;
	my @components;
	for my $engine ($self->all_engines) {
		while ((my ($enginename, $components)) = each %$engine) {
			for my $component (@$components) {
			my $componentname = $component->{name};
			$component->{fullname} = join '_', $enginename, $componentname;
			push @components, $component;
			}
		}
	}
	return \@components;
}

=head2 components_href

Return all components from the recipe as a hashref

=cut

sub components_href {
	my $self = shift;
	my %components;
	for my $engine ($self->all_engines) {
		while ((my ($enginename, $components)) = each %$engine) {
			for my $component (@$components) {
			my $componentname = $component->{name};
			$components{$enginename}{$componentname} = $component;
			}
		}
	}
	return \%components;
}

=head2 conditions

Return all conditions from the recipe as a hashref

=cut

sub conditions {
	my $self = shift;
	my %conditions;
	for my $engine ($self->all_engines) {
		while ((my ($enginename, $components)) = each %$engine) {
			for my $component (@$components) {
			my $componentname = $component->{name};
			$conditions{$enginename}{$componentname} = $component->{conditions};
			}
		}
	}
	return \%conditions;
}

=head2 parts

Return all parts from the recipe as a hashref

=cut

sub parts {
	my $self = shift;
	my %parts;
	for my $engine ($self->all_engines) {
		while ((my ($enginename, $components)) = each %$engine) {
			for my $component (@$components) {
			my $componentname = $component->{name};
			$parts{$enginename}{$componentname} = $component->{steps};
			}
		}
	}
	return \%parts;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

