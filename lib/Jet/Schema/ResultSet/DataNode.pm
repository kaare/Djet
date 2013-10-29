package Jet::Schema::ResultSet::DataNode;
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

Thus, we're sure always to have to whole branch, and we can also find the
arguments of the request

As a side effect this method sets rest_path.

=cut

sub find_basenode {
	my ($self, $path) = @_;
	my $datanodes = $self->search({node_path => { '@>' => $path } }, {order_by => \'length(node_path) DESC' });
    my $basenode = $datanodes->first or return;

    my $base_path = $basenode->node_path;
    my $rest = $path;
    $rest =~ s|^$base_path/*||;
    $self->set_rest_path($rest);
	return $datanodes;
}

1;

# COPYRIGHT

__END__
