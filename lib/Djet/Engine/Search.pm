package Djet::Engine::Search;

use 5.010;
use Moose;
use Encode qw/decode/;

extends 'Djet::Engine::Default';

with 'Djet::Part::List';

=head1 NAME

Djet::Engine::Search - Search Engine

=head1 METHODS

=head2 init

Find the nodes based on the search string

=cut

after 'init_data' => sub  {
	my $self = shift;
	my $search_phrase = decode('utf-8', $self->body->request->parameters->{search_phrase});
	return unless $search_phrase;

	$self->add_search(node_path => {'<@', $self->stash->{payload}->domain_node->node_path});
	$self->set_fts($search_phrase);
	$self->set_list_name('search_nodes');
	$self->stash->{search_phrase} = $search_phrase;
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
