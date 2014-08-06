package Jet::Trait::Field::Structured;

use Moose::Role;
use YAML::Tiny;

=head1 NAME

Jet::Trait::Field::Structured

=cut

requires qw/value/;

=head1 METHODS

=head2 pack

Pack a structured field

=cut

sub pack {
	my ($self, $value) = @_;
use Data::Dumper 'Dumper';
warn Dumper [ YAML::Tiny::Load($value)];
	return $value;
}

1;
