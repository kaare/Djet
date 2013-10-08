package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Log/;

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 DESCRIPTION

Jet::Engine::Default is the basic Jet Engine.

=head1 ATTRIBUTES

=head2 parts

This is the engine parts

=cut

has parts => (
	traits	=> [qw/Jet::Trait::Partname/],
	is		=> 'ro',
	isa	   => 'ArrayRef',
	parts => [
		{'Jet::Part::Basenode' => 'jet_basenode'},
		{
			module => 'Jet::Part::Children',
			alias  => 'jet_children',
			type => 'json',
		},
	],
);

no Moose;

=head1 METHODS

=cut

__PACKAGE__->meta->make_immutable;

1;

__END__

