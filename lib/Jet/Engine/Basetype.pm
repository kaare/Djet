package Jet::Engine::Basetype;

use 5.010;
use Moose;
use JSON;

use Jet::Engine::Recipe;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Basetype - Jet Engine Basetype Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engine basetypes.

=head1 ATTRIBUTES

=head3 json

For (de)serializing data

=head3 raw

The basetype in raw (serialized) form

=cut

has 'json' => (
	isa => 'JSON',
	is => 'ro',
	default => sub {
		JSON->new();
	},
	lazy => 1,
);
has basetype => (
	isa => 'HashRef',
	is => 'ro',
);
has recipe => (
	isa => 'Jet::Engine::Recipe',
	is => 'ro',
);
has role => (
	isa => 'Object',
	is => 'ro',
);

=head1 METHODS

=head2 bind

=cut

sub bind {
}

__PACKAGE__->meta->make_immutable;

1;
__END__

