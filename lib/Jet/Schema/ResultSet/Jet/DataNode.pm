package Jet::Schema::ResultSet::Jet::DataNode;
use base 'DBIx::Class::ResultSet';

use Moose;
use namespace::autoclean;
use utf8;

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

As a side effect this method sets rest_path.

=cut

sub find_basenode {
	my ($self, $path) = @_;
	my @datanodes = $self->search({node_path => { '@>' => $path } }, {order_by => \'length(node_path) DESC' })->all;
	my $basenode = $datanodes[0] or return;

	my $base_path = $basenode->node_path;
	if ( $path =~ m|^$base_path/(.*)|) {
		$self->set_rest_path($1);
	}
	return \@datanodes;
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

=head2 normalize_part

Take some text and make a nice part out of it

 - lowercase it
 - turn spaces into underscores

=cut

sub normalize_part {
	my ( $self, $text ) = @_;
	my $part = lc $text;
	$part =~ s/\s+/_/g;
	$part =~ tr/æøå/aoa/;
	return $part;
}

1;

# COPYRIGHT

__END__
