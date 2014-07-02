package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';

with qw/
	Jet::Role::Engine::Html
	Jet::Role::Engine::Json
	Jet::Role::Treeview
/;

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 DESCRIPTION

Jet::Engine::Default is the basic Jet Engine.

It includes the roles L<Jet::Role::Engine::Html>, L<Jet::Role::Engine::Json>, L<Jet::Role::Treeview>.

=head1 ACCESSORS

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

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
