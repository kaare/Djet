package Jet::Trait::Field::Structured;

use Moose::Role;
use YAML::Tiny;

=head1 NAME

Jet::Trait::Field::Structured

=head1 DESCRIPTION

Structured data. Input format is expected as pseudo yaml (yaml w/o the initial ---).

=cut

requires qw/value/;

=head1 METHODS

=head2 pack

Pack a structured field

=cut

sub pack {
	my ($self, $value) = @_;
	my $new;
	eval {$new = YAML::Tiny::Load("---\n" . $value) };
	return $@ ? $value : $new;
}

1;
