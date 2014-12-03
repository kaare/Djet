package Djet::Engine::Children;

use 5.010;
use Moose;

extends 'Djet::Engine::Default';
with qw/Djet::Part::List/;

=head1 NAME

Djet::Engine - Children Jet Engine

=head1 DESCRIPTION

Djet::Engine::Children is the basic Jet Engine.

It includes the role L<Djet::Part::List>.

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
