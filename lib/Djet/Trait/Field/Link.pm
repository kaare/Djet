package Djet::Trait::Field::Link;

use Moose::Role;
use YAML::Tiny;

=head1 NAME

Djet::Trait::Field::Link

=head1 DESCRIPTION

Link fields

=cut

=head1 ATTRIBUTES

=head2 uri

The uri points to something representing this field

=cut

has 'uri' => (
	is => 'ro',
	isa => 'Str',
);

no Moose::Role;

1;
