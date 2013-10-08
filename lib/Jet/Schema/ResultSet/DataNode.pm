package Jet::Schema::ResultSet::DataNode;
use base 'DBIx::Class::ResultSet';

=head2 find_basenode

Find the basenode

Returns a set of rows as an arrayref, starting from the basenode and with the root last.

Thus, we're sure always to have to whole branch, and we can also find the
arguments of the request

=cut

sub find_basenode {
	my ($self, $path) = @_;
	$path =~ s|^(.*?)/?$|$1|; # Remove last character if slash
	return $self->search({node_path => { '@>' => $path } }, {order_by => \'length(node_path) DESC' });
}

1;
