package Djet::Part::Update::Node;

use MooseX::MethodAttributes::Role;

with 'Djet::Part::Update';

requires qw/edit_validation edit_update edit_create/;

=head1 NAME

Djet::Part::Update::Node

=head1 DESCRIPTION

A Role for creating and editing Nodes

Handles create and edit functionality of datanodes for Djet Engines

=head1 ATTRIBUTES

=head2 edit_cols

Names of columns that will be edited in the engine itself, i.e. not stored

=cut

has edit_cols => (
	is => 'ro',
	isa => 'ArrayRef',
	lazy => 1,
	default => sub { [qw/datacolumns/] },
);

=head2 dont_save

Names of columns that will not be saved

For datanodes, this will default be what's in edit_cols plus id, created, modified, plus whichever fields shouldn't be stored (storage: false)

=cut

has dont_save => (
	is => 'ro',
	isa => 'ArrayRef',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $basetype = $self->model->basetypes->{$self->object->basetype_id}; # Should be faster; already in memory
		my @cols = map {$_->{name}} grep {defined $_->{storage} && !$_->{storage}} @{ $basetype->datacolumns };
		return \@cols;
	},
);

=head1 METHODS

=head2 set_base_object

Set the object to the basenode

=cut

sub set_base_object {
	my $self = shift;
	my $rest_path = $self->rest_path;
	if (defined($rest_path) and $rest_path =~ /^\d+$/a and my $node = $self->model->resultset('Djet::DataNode')->find({node_id => $rest_path})) {
		$self->set_object($node);
	}
	$self->set_object($self->basenode) unless $self->has_object;
}

=head2 _build_dfv

Build the dfv for a node

=cut

sub _build_dfv {
	my $self = shift;
	my $nodedata = $self->object->nodedata;
	return $nodedata->dfv;
}

=head2 get_fieldnames

Get the fieldnames of the object

=cut

sub get_fieldnames {
	my $self = shift;
	my $cols = $self->object->nodedata;
	return $cols->fieldnames;
}

=head2 datacolumns

Get the datacolumns from input data

=cut

sub datacolumns {
	my ($self, $input_data) = @_;
	my $fieldnames = $self->get_fieldnames;
	my $nodedata = $self->object->nodedata;
	# call unpack on each datacolumns field. Perhaps there is a convertion
	return { map { $_ => $nodedata->$_->unpack($input_data->{$_}) } @$fieldnames };
}

=head2 get_resultset

Get the resultset to be used for creating objects

=cut

sub get_resultset {
	my $self = shift;
	return $self->model->resultset('Djet::DataNode');
}

=head2 get_base_name

Get the name to be used for error messages and such

=cut

sub get_base_name {
	my $self = shift;
	return $self->basenode->basetype->name;
}

=head2 create_path

Process the POST request for creating a node

=cut

sub create_path {
	my $self = shift;
	$self->stash_basic;
	$self->stash->{payload}->urify($self->object);
}

=head2 after edit_update

Do an update_fts

=cut

after 'edit_update' => sub {
	my ($self, $validation)=@_;
	my $config = $self->config;
	my $fts_config = $config->config->{fts_config};
	my $object = $self->object;
	$object->update_fts($fts_config);
};

=head2 after edit_create

Do an update_fts

=cut

after 'edit_create' => sub {
	my ($self, $validation)=@_;
	my $config = $self->config;
	my $fts_config = $config->config->{fts_config};
	my $object = $self->object;
	$object->update_fts($fts_config);
};

1;
