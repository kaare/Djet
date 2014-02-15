package Jet::Part::List;

use 5.010;
use Moose::Role;
use namespace::autoclean;

with 'Jet::Part';

=head1 NAME

Jet::Part::List - Find a number of nodes based on some earch parameters

=head1 ATTRIBUTES

=head2 limit

Limit the number of nodes to be returned

=cut

has limit => (
	is => 'ro',
	isa => 'Int',
	predicate => 'has_limit',
	writer => 'set_limit',
);

=head2 fts

A full-text search string

=cut

has fts => (
	is => 'ro',
	isa => 'Str',
	predicate => 'has_fts',
);

=head2 search

A generic DBIC seach parameter arrayref

=cut

has search => (
	is => 'ro',
	isa => 'HashRef',
	traits => [qw/Hash/],
	lazy => 1,
	default => sub { {} },
	handles => {
		add_search => 'set',
	},
);

=head1 METHODS

=head2 init

Find the nodes with the parameters given

=cut

after init => sub {
	my $self = shift;
	$self->stash->{children} = $self->_find_list;
};

sub _find_list {
	my $self = shift;
	my $options = {};
	$options->{limit} = $self->limit if $self->has_limit;
	my $search = $self->schema->resultset('Jet::DataNode')->search($self->search, $options);
	return $self->has_fts ? $search->ft_search($self->fts) : $search;
}

no Moose::Role;

1;

# COPYRIGHT

__END__
