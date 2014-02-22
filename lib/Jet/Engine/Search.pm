package Jet::Engine::Search;

use 5.010;
use Moose;
use Encode qw/encode/;

extends 'Jet::Engine::Default';

=head1 NAME

Jet::Engine::Search - Search Engine

=head1 METHODS

=head2 init

Find the nodes based on the search string

=cut

sub init {
	my $self = shift;
	my $search_phrase = encode('utf-8', $self->request->request->parameters->{search_phrase});
	$self->stash->{search_nodes} = $self->schema->resultset('Jet::DataNode')->search(undef, {rows => 10})->ft_search($search_phrase);
	$self->stash->{search_phrase} = $search_phrase;
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
