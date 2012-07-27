package Jet::Engine;

use 5.010;
use Moose;


with qw/Jet::Role::Log MooseX::Traits/;

=head1 NAME

Jet::Engine - Jet Engine Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engines.

In your engine you just write

extends 'Jet::Engine';

=head1 ATTRIBUTES

=cut

has config => (
	isa => 'Jet::Config',
	is => 'ro',
);
has schema => (
	isa => 'Jet::Stuff',
	is => 'rw',
);
has cache => (
	isa => 'Object',
	is => 'ro',
);
has basetypes => (
	isa       => 'HashRef',
	is        => 'ro',
);
has stash => (
	isa => 'HashRef',
	is => 'ro',
);
has request => (
	isa => 'Plack::Request',
	is => 'ro',
);
has basenode => (
	isa => 'Jet::Basenode',
	is => 'ro',
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
);
has run_components => (
	traits  => ['Array'],
	isa     => 'ArrayRef[HashRef]',
	is => 'rw',
	handles => {
		all_components    => 'elements',
		add_component     => 'push',
		map_components    => 'map',
		filter_components => 'grep',
		find_component    => 'first',
		get_component     => 'get',
		join_components   => 'join',
		count_components  => 'count',
		has_components    => 'count',
		has_no_components => 'is_empty',
		sorted_components => 'sort',
	},
);

__PACKAGE__->meta->make_immutable;

1;
__END__

