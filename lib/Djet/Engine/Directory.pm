package Djet::Engine::Directory;

use 5.010;
use Moose;

extends 'Djet::Engine::Default';
with qw/
	Djet::Part::List
/;

=head1 NAME

Djet::Engine - Directory Djet Engine

=head1 DESCRIPTION

Djet::Engine::Directory is the basic Djet Engine for Directory nodes.

It includes the role L<Djet::Part::List>.

=head1 METHODS

=head2 init

Init the list part

=cut

after 'init_data' => sub {
	my $self = shift;
	$self->add_search(parent_id => $self->model->basenode->node_id);
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
