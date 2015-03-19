package Djet::Engine::Admin::Basetype;

use 5.010;
use Moose;

extends 'Djet::Engine::Default';
with qw/
	Role::Pg::Notify
	Djet::Part::Update::Basetype
	Djet::Part::Config::Topmenu
/;

=head1 DESCRIPTION

Djet::Engine::Admin::Basetype configures Djet basetypes.

=head1 ATTRIBUTES

=head1 METHODS

=head2 _build_notify_dbh

Build the notify dbh from the model's storage.

Keeps Role::Pg::Notify happy.

=cut

sub _build_notify_dbh {
	my $self = shift;
	return $self->model->storage->dbh;
}

=head2 set_base_object

Override the default basetype setter. Find the basetype being edited right now

=cut

sub set_base_object {
	my $self = shift;
	my $model = $self->model;
	my $rest_path = $model->rest_path;
	undef($rest_path) if $rest_path eq 'index.html';
	if (!$rest_path) {
		$self->set_object($model->resultset('Djet::Basetype')->new({
			feature_id => 1,
			datacolumns => '[]',
			attributes => '{}',
		}));
		$model->stash->{title} = 'New basetype';
		$self->is_new(1);
		return;
	}

	if (my ($current_basetype) = grep {$rest_path eq $_->name} values %{ $model->basetypes }) {
		$self->set_object($current_basetype);
	}
}

=head2 data

Sort the basetypes and set the stash

=cut

before data => sub {
	my $self = shift;
	my $model = $self->model;
	my $stash = $model->stash;
	$stash->{sorted_basetypes} = [ sort {$a->name cmp $b->name} values $model->basetypes ];
	if ($self->has_object) {
		$stash->{title} ||= $self->object->title;
		$stash->{current_basetype} = $self->object;
		$self->_build_basetype_fields($self->object);
	}
};

=head2 after edit_updated

Send notification that the basetype has changed

=cut

after 'edit_updated' => sub  {
	my $self = shift;
	$self->notify(queue => 'djet:admin', payload => 'reload:basetype:' . $self->object->id);
};

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
			name => 'title',
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
	my $datacolumns = {
		prefix => 'datacolumn',
		header => [qw/Name Title Type Searchable Required/],
		rows => [map {
			my $col = $_;
			[{
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
				default => [qw/Boolean Email Enum File Html Int Price Str Structured/],
				value => $col->{type},
				updatable => 1,
			},
			{
				name => 'searchable',
				title => 'Searchable',
				type => 'Boolean',
				updatable => 1,
				value => (grep {$col->{name} && $col->{name} eq $_} @{ $current_basetype->searchable || [] }) ? 1 : 0,
			},
			{
				name => 'required',
				title => 'Required',
				type => 'Boolean',
				updatable => 1,
			},
		]} @{ $current_basetype->datacolumns }, {} ],
	};
	my $attributes = {
		prefix => 'attribute',
		header => [qw/Name Value/],
		rows => [map {
			my $key = $_;
			my $val = $current_basetype->attributes->{$key};
			[{
				name => 'name',
				title => 'Name',
				type => 'Str',
				value => $key,
				updatable => 1,
			},
			{
				name => 'value',
				title => 'Value',
				type => 'Str',
				value => $val,
				updatable => 1,
			},
		]} sort keys %{ $current_basetype->attributes }, ''],
	};
	my $model = $self->model;
	$model->stash->{fields} = $fields;
	$model->stash->{datacolumns} = $datacolumns;
	$model->stash->{attributes} = $attributes;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
