package Djet::Schema::ResultSet::Djet::DataNode;
use base 'DBIx::Class::ResultSet';

use Moose;
use namespace::autoclean;
use utf8;

=head1 METHODS

=head1 search modifying methods

Add an attribute to the search

=head2 rows

Limit the search to the given number of rows.

10 is an often used limit so that is the default.

=cut

sub rows {
	my ($self, $limit) = @_;
	$limit ||= 10;
	return $self->search({}, { rows => $limit })
}

=head2 data_modified_lowest_first

Sort by data_modified, lowest first

=cut

sub data_modified_lowest_first {
	my $self = shift;
	return $self->search({}, { order_by => 'data_modified' })
}

=head2 data_modified_highest_first

Sort by data_modified, highest first

=cut

sub data_modified_highest_first {
	my $self = shift;
	return $self->search({}, { order_by => {-desc => 'data_modified'} })
}

=head2 all_ref

Returns all rows, as an arrayref

=cut

sub all_ref {
	my $self = shift;
	return [ $self->all ];
}

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
	return $self->search(
		{
			'me.fts' => \"@@ to_tsquery( '$search_language', $q )",
		}
	);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

# COPYRIGHT

__END__
