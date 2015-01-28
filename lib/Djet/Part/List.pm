package Djet::Part::List;

use 5.010;
use Moose::Role;
use namespace::autoclean;

with 'Djet::Part';

=head1 NAME

Djet::Part::List

=head1 DESCRIPTION

Find a number of nodes based on some search parameters, and put them on the stash

=head1 ATTRIBUTES

=head2 list_name

Name of the list on the stash

=cut

has list_name => (
	is => 'ro',
	isa => 'Str',
	writer => 'set_list_name',
	default => 'children',
);

=head2 limit

Limit the number of nodes to be returned

If the limit is negative, the search will not be performed

=cut

has limit => (
	is => 'ro',
	isa => 'Int',
	writer => 'set_limit',
	default => 10,
);

=head2 fts

A full-text search string

=cut

has fts => (
	is => 'ro',
	isa => 'Str',
	predicate => 'has_fts',
	writer => 'set_fts',
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

before 'data' => sub {
	my $self = shift;
	$self->stash->{$self->list_name} = $self->_find_list;
};

sub _find_list {
	my $self = shift;
	return if $self->limit < 0;

	my $options = {};
	$options->{rows} = $self->limit;
	my $page = $self->request->param('page') // 1;
	$options->{page} = $page;
	delete $self->stash->{query_parameters}{page};
	my $search = $self->schema->resultset('Djet::DataNode')->search($self->search, $options);
	return $search unless $self->has_fts;

	my $config = $self->config;
	my $fts_config = $config->config->{fts_config};
	return $search->ft_search($fts_config, $self->fts);
}

no Moose::Role;

1;

# COPYRIGHT

__END__
