package Djet::Schema::ResultSet::Djet::DataNode;
use base 'DBIx::Class::ResultSet';

use Moose;
use namespace::autoclean;
use utf8;

=head1 METHODS

=head2 all_ref

Returns all rows, as an arrayref

=cut

sub all_ref {
	my $self = shift;
	return [ $self->all ];
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

=head1 METHODS

=head2 ft_search

Do a full-text search on current resultset.

params is either an arrayref or a text with search items

=cut

sub ft_search {
	my ( $self, $search_language, $params ) = @_;
	my @words = ref $params eq 'ARRAY' ? @$params :
		!ref $params ? split /\s+/, $params :
		return $self; # We can't handle this

	my $q = $self->result_source->schema->storage->dbh->quote( join '|',  @words );
	return $self->search( {
			fts => \"@@ to_tsquery( '$search_language', $q )",
		}
	);
}

1;

# COPYRIGHT

__END__
