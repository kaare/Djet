package Jet::Role::Update::Basetype;

use MooseX::MethodAttributes::Role;

=head1 NAME

Jet::Role::Update::Basetype - Role for creating and editing Basetypes

=head1 DESCRIPTION

Handles create and edit functionality of basetypes for Jet Engines

=cut

with 'Jet::Role::Update';

requires qw/edit edit_validation edit_update edit_create/;

=head2 set_base_object

Set the object to the basenode

=cut

sub set_base_object {
	my $self = shift;
	$self->set_object($self->basenode->basetype);
}

=head2 get_validator

Get the validator for the object

=cut

sub get_validator {
	my $self = shift;
	my $basetype = $self->object;
	return $basetype->validator;
}

=head2 get_fieldnames

Get the fieldnames of the object

=cut

sub get_fieldnames {
	my $self = shift;
	return [ $self->object->result_source->columns ];
}

=head2 get_resultset

Get the resultset to be used for creating objects

=cut

sub get_resultset {
	my $self = shift;
	return $self->schema->resultset('Basetype');
}

=head2 get_base_name

Get the name to be used for error messages and such

=cut

sub get_base_name {
	my $self = shift;
	return $self->object->name;
}

=head2 redirect_to

Return the path to be redirected to after a successful update.

=cut

sub redirect_to {
	my $self = shift;
warn 1;
warn $self->object->name;
warn 2;
	return '/jet/config/basetype/' . $self->object->name;
}

1;
