package Jet::Engine::Control;

use 5.010;
use Moose;

use Jet::Engine::Control::Omit;

=head1 NAME

Jet::Engine::Control - Controls the Jet Engine

=head1 DESCRIPTION

Jet::Engine::Control is used as an attribute in Jet::Engine. In any engine it's
possible to tell Jet to omit some steps, or to skip the rest of the step.

=head1 SYNOPSIS

In the engine class

$self->control->omit->init('init step');
$self->control->omit->data('data step');
$self->control->omit->render('render step');

or

$self->control->skip('init');
$self->control->skip('data');
$self->control->skip('render');

=head1 ATTRIBUTES

=head2 omit

=cut

has omit => (
	is	=> 'ro',
	isa => 'Jet::Engine::Control::Omit',
	default => sub { Jet::Engine::Control::Omit->new },
	lazy => 1,
);

=head2 _skip

=cut

has _skip => (
	is	=> 'ro',
	isa => 'ArrayRef',
	traits => ['Array'],
	default => sub { [] },
	lazy => 1,
	handles => {
		skip => 'push',
		clear_skip => 'clear',
		first_skip => 'first',
	 },
);

no Moose;

=head1 METHODS

=cut

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__

