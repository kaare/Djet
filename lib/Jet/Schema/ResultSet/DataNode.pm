package Jet::Schema::ResultSet::DataNode;
use base 'DBIx::Class::ResultSet';

=head2 find_basenode

Find the basenode

Returns a set of rows as an arrayref, starting from the basenode and with the root last.

Thus, we're sure always to have to whole branch, and we can also find the
arguments of the request

NB find_nodebranch is under repair atm, so this is a pass through to find_node.

=cut

sub find_basenode {
	my $self = shift;
	$path =~ s|^(.*?)/?$|$1|; # Remove last character if slash
	my $nodedata;
	$nodedata = $request->schema->find_basenode({ node_path => $path });

	# Try again to see if the last part was a parameter
	if (!$nodedata) {
		my @segments = $request->request->uri->path_segments;
		my $argument = pop @segments;
		$nodedata = $request->schema->find_basenode({ node_path => join '/', @segments });
		$request->set_arguments([$argument // '']);
	}
}

1;
