package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Log/;

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

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 SYNOPSIS

Jet::Engine::Default is the basic Jet Engines.

=head1 ATTRIBUTES

=cut

=head2 arguments

This is the set of arguments for this engine

=cut


=head1 METHODS

=cut

__PACKAGE__->meta->make_immutable;

1;

__END__

