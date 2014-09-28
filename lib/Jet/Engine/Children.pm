package Jet::Engine::Children;

use 5.010;
use Moose;

extends 'Jet::Engine::Default';
with qw/Jet::Part::List/;

=head1 NAME

Jet::Engine - Children Jet Engine

=head1 DESCRIPTION

Jet::Engine::Children is the basic Jet Engine.

It includes the role L<Jet::Part::List>.

=head1 METHODS

=head2 init

Init the list part

=cut

after 'init_data' => sub {
	my $self = shift;
	$self->add_search(parent_id => $self->basenode->node_id);
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
