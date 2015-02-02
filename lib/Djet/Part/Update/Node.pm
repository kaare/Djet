package Djet::Part::Update::Node;

use MooseX::MethodAttributes::Role;

=head1 NAME

Djet::Part::Update::Node - Role for creating and editing Nodes

=head1 DESCRIPTION

Handles create and edit functionality of datanodes for Djet Engines

=cut

with 'Djet::Part::Update';

requires qw/edit_validation edit_update edit_create/;

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
	my $fields = $self->object->fields;
	return $fields->dfv;
}

=head2 get_fieldnames

Get the fieldnames of the object

=cut

sub get_fieldnames {
	my $self = shift;
	my $cols = $self->object->fields;
	return $cols->fieldnames;
}

=head2 datacolumns

Get the datacolumns from input data

=cut

sub datacolumns {
	my ($self, $input_data) = @_;
	my $fieldnames = $self->get_fieldnames;
	my $fields = $self->object->fields;
	# call unpack on each datacolumns field. Perhaps there is a convertion
	return { map { $_ => $fields->$_->unpack($input_data->{$_}) } @$fieldnames };
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

1;
