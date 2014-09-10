package Jet::Role::Engine;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Engine

=head1 DESCRIPTION

The parts that go into an engine.

=head1 ATTRIBUTES

=head2 omit_run

Set one of the following entries to true in this hashref:

	init_data
	to_html
	data

To stop Jet from processing that method.

=cut

has 'omit_run' => (
	is => 'ro',
	isa => 'HashRef',
	default => sub { {} },
);

no Moose::Role;

1;

# COPYRIGHT

__END__
