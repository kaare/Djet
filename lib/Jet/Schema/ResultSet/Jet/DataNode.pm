package Jet::Schema::ResultSet::Jet::DataNode;
use base 'DBIx::Class::ResultSet';

use Moose;
use namespace::autoclean;

=head1 ATTRIBUTES

=head2 rest_path

The remaining part after the basenode has been found.

=cut

has rest_path => (
	 is => 'ro',
	 isa => 'Str',
	 writer => 'set_rest_path',
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

=head1 METHODS

=head2 find_basenode

Find the basenode

Returns a set of rows as an arrayref, starting from the basenode and with the root last.

Thus, we're sure always to have to whole branch, and we can also find the arguments of the request

If the basenode is a directory (ends in "/") we try to see if there is an index.html node for it.

As a side effect this method sets rest_path.

=cut

sub find_basenode {
	my ($self, $path) = @_;
	my $node_path = $path =~ /\/$/ ? "$path/index.html" : $path;
	my $datanodes = $self->search({node_path => { '@>' => $path } }, {order_by => \'length(node_path) DESC' });
	my $basenode = $datanodes->first or return;

	my $base_path = $basenode->node_path;
	if ( $path =~ m|^$base_path/(.*)|) {
		$datanodes->set_rest_path($1);
	}
	return $datanodes;
}

=head2 ft_search

Do a full-text search on current resultset.

params is either an arrayref or a text with search items

=cut

sub ft_search {
	my ( $self, $params ) = @_;
	my @words = ref $params eq 'ARRAY' ? @$params :
		!ref $params ? split /\s+/, $params :
		return $self; # We can't handle this

	my $q = $self->result_source->schema->storage->dbh->quote( join '|',  @words );
	return $self->search( {
			fts => \"@@ to_tsquery( $q )",
		}
	);
}

1;

# COPYRIGHT

__END__
