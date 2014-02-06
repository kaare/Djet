package Jet::Role::Update::Node;

use MooseX::MethodAttributes::Role;

=head1 NAME

Jet::Role::Update::Node - Role for creating and editing Nodes

=head1 DESCRIPTION

Handles create and edit functionality of datanodes for Jet Engines

=cut

with 'Jet::Role::Update';

requires qw/edit edit_validation edit_update edit_create/;

=head1 ATTRIBUTES

=head2 edit_cols

Names of columns that will be edited in the engine itself

=cut

has edit_cols => (
	is => 'ro',
	isa => 'ArrayRef',
	lazy => 1,
	default => sub { [qw/datacolumns/] },
);

=head1 METHODS

=head2 set_base_object

Set the object to the basenode

=cut

sub set_base_object {
	my $self = shift;
	$self->set_object($self->basenode);
}

=head2 get_validator

Get the validator for the object

=cut

sub get_validator {
	my $self = shift;
	my $basetype = $self->basenode->basetype;
	return $basetype->validator;
}

=head2 get_fieldnames

Get the fieldnames of the object

=cut

sub get_fieldnames {
	my $self = shift;
	my $fields = $self->object->fields;
	return $fields->fieldnames;
}

=head2 datacolumns

Get the datacolumns from input data

=cut

sub datacolumns {
	my ($self, $input_data) = @_;
	my $fieldnames = $self->get_fieldnames;
	return { map { $_ => $input_data->{$_} } @$fieldnames };
}

=head2 get_resultset

Get the resultset to be used for creating objects

=cut

sub get_resultset {
	my $self = shift;
	return $self->schema->resultset('DataNode');
}

=head2 get_base_name

Get the name to be used for error messages and such

=cut

sub get_base_name {
	my $self = shift;
	return $self->basenode->basetype->name;
}

=head2 redirect_to

Return the path to be redirected to after a successful update.

=cut

sub redirect_to {
	my $self = shift;
	return $self->object->node_path;
}

1;
