package Djet::Part::Engine;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Engine

=head1 DESCRIPTION

The parts that go into an engine.

=head1 ATTRIBUTES

=head2 return_value

Set return_value in init_data or data to skip the rest of the processing and return directly.

Example

	$self->return_value(\302);

=cut

has 'return_value' => (
	is => 'rw',
	predicate => 'has_return_value',
);

no Moose::Role;

1;

# COPYRIGHT

__END__
