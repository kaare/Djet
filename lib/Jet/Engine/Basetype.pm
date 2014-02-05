package Jet::Engine::Basetype;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Update::Basetype Jet::Role::Log/;

=head1 DESCRIPTION

Jet::Engine::Basetype configures Jet basetypes.

=head1 ATTRIBUTES

=head2 parts

This is the engine parts

=cut

has _parts => (
	traits	=> [qw/Jet::Trait::Engine/],
	is		=> 'ro',
	isa		=> 'ArrayRef',
	parts => [
	],
);

=head1 METHODS

=head2 set_base_object

Override the default basetype setter. Find the basetype being edited right now

=cut

sub set_base_object {
	my $self = shift;
	my $rest_path = $self->response->data_nodes->rest_path;
	if (my ($current_basetype) = grep {$rest_path eq $_->name} values %{ $self->schema->basetypes }) {
		$self->set_object($current_basetype);
	}
}

=head2 data

Basically, just edit functionality

=cut

before data => sub {
	my $self = shift;
	$self->edit;
};

=head2 edit_view

Find the data to put on stash

=cut

sub edit_view {
	my $self = shift;
	$self->stash->{request} = $self->request;
	my $nodes = $self->response->data_nodes;
	my @basetypes = $self->schema->resultset('Basetype')->search(undef, {order_by => 'id'});
	$self->stash->{basetypes} = [ @basetypes ];
	if ($self->has_object) {
		$self->stash->{title} ||= $self->object->title;
		$self->stash->{current_basetype} = $self->object;
		$self->_build_basetype_fields($self->object);
	}

	# Return
	my $response = $self->response;
	$response->template('config/basetype.tx');
}

sub _build_basetype_fields {
	my ($self, $current_basetype) = @_;
	my $fields = [
		{
			name => 'name',
			title => 'Name',
			type => 'Str',
			value => $current_basetype->name,
			updatable => 1,
		},
		{
			title => 'title',
			title => 'Title',
			type => 'Str',
			value => $current_basetype->title,
			updatable => 1,
		},
		{
			name => 'handler',
			title => 'Handler',
			type => 'Str',
			value => $current_basetype->handler,
			updatable => 1,
		},
		{
			name => 'template',
			title => 'Template',
			type => 'Str',
			value => $current_basetype->template,
			updatable => 1,
		},
	];
use Data::Dumper;
warn Dumper $current_basetype->searchable;
warn ref $current_basetype->datacolumns;
	my $datacolumns = {
		prefix => 'datacolumn',
		header => [qw/Name Title Type Searchable Required/],
		rows => [map {
			my $col = $_;
			[
			{
				name => 'name',
				title => 'Name',
				type => 'Str',
				value => $col->{name},
				updatable => 1,
			},
			{
				name => 'title',
				title => 'Title',
				type => 'Str',
				value => $col->{title},
				updatable => 1,
			},
			{
				name => 'type',
				title => 'Type',
				type => 'Enum',
				enum => [qw/Boolean Enum Html Int Str/],
				value => $col->{type},
				updatable => 1,
			},
			{
				name => 'searchable',
				title => 'Searchable',
				type => 'Boolean',
				updatable => 1,
				value => grep {$col->{name} eq $_} @{ $current_basetype->searchable },
			},
			{
				name => 'required',
				title => 'Required',
				type => 'Boolean',
				updatable => 1,
			},
		]} @{ $current_basetype->datacolumns }],
	};
	push @{ $datacolumns->{rows} }, [
		{
			name => 'name',
			title => 'Name',
			type => 'Str',
			updatable => 1,
		},
		{
			name => 'title',
			title => 'Title',
			type => 'Str',
			updatable => 1,
		},
		{
			name => 'type',
			title => 'Type',
			type => 'Enum',
			enum => [qw/Boolean Enum Html Int Str/],
			updatable => 1,
		},
		{
			name => 'searchable',
			title => 'Searchable',
			type => 'Boolean',
			value => 1,
			updatable => 1,
		},
		{
			name => 'required',
			title => 'Required',
			type => 'Boolean',
			updatable => 1,
		},
	];
	$self->stash->{fields} = $fields;
	$self->stash->{datacolumns} = $datacolumns;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
