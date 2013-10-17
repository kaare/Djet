package Jet::Engine::Control::Omit;

use 5.010;
use Moose;

=head1 NAME

Jet::Engine::Control::Omit

=head1 DESCRIPTION


=head1 ATTRIBUTES

=head2 _init

=cut

has _init => (
	is	=> 'ro',
	isa => 'ArrayRef',
	traits => ['Array'],
	default => sub { [] },
	lazy => 1,
	handles => {
		init => 'push',
		clear_init => 'clear',
		first_init => 'first',
	},
);

=head2 _data

=cut

has _data => (
	is	=> 'ro',
	isa => 'ArrayRef',
	traits => ['Array'],
	default => sub { [] },
	lazy => 1,
	handles => {
		data => 'push',
		clear_data => 'clear',
		first_data => 'first',
	},
);

=head2 _render

=cut

has _render => (
	is	=> 'ro',
	isa => 'ArrayRef',
	traits => ['Array'],
	default => sub { [] },
	lazy => 1,
	handles => {
		render => 'push',
		clear_render => 'clear',
		first_render => 'first',
	},
);

no Moose;

=head1 METHODS

=cut

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__

