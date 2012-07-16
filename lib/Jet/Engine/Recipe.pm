package Jet::Engine::Recipe;

use 5.010;
use Moose;
use JSON;

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

=cut

has 'json' => (
	isa => 'JSON',
	is => 'ro',
	default => sub {
		JSON->new();
	},
	lazy => 1,
);
has raw => (
	is => 'ro',
	isa => 'Str',
);
has recipe => (
	traits  => ['Array'],
	isa     => 'ArrayRef[HashRef]',
	is => 'ro',
	default => sub {
		my $self = shift;
		$self->raw ? {self => $self->json->encode($self->raw)} : [];
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

__PACKAGE__->meta->make_immutable;

1;
__END__

