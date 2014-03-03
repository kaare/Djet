package Jet::Role::Update::Basetype;

use MooseX::MethodAttributes::Role;
use List::MoreUtils qw{ any };

=head1 NAME

Jet::Role::Update::Basetype - Role for creating and editing Basetypes

=head1 DESCRIPTION

Handles create and edit functionality of basetypes for Jet Engines

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
	default => sub { [qw/attributes datacolumns searchable/] },
);

=head1 METHODS

=head2 set_base_object

Set the object to the basenode

=cut

sub set_base_object {
	my $self = shift;
	$self->set_object($self->basenode->basetype);
}

=head2 _build_dfv

Build the validator init hashref for the object

=cut

sub _build_dfv {
	my $self = shift;
	my $basetype = $self->object;
	my $colnames = $self->get_colnames;
	my $required = [ qw/name title/ ];
	my $optional = [ grep {my $colname = $_;!any{ $colname eq $_ } @$required, 'parent' } @$colnames ];
	my $dfv = {
		required => $required,
		optional => $optional,
		filters  => 'trim',
		field_filters => { },
		constraint_methods => { },
	};
	return $dfv;
}

=head2 attributes

Get the attributes from input data

=cut

sub attributes {
	my ($self, $input_data) = @_;
	my $prefix = 'attribute';
	my $params = $self->request->request->body_parameters;
	my $rows = $self->find_rows_from_params($prefix, $params);
	my %attributes = map {$_->{name} => $_->{value}} grep {$_->{name}} @$rows;
	return \%attributes;
}

=head2 datacolumns

Get the datacolumns from input data

=cut

sub datacolumns {
	my ($self, $input_data) = @_;
	my $prefix = 'datacolumn'; # XXX
	my $params = $self->request->request->body_parameters;
	my $rows = $self->find_rows_from_params($prefix, $params);

	# Merge any existing values that are NOT in the web form
	my $object = $self->object;
	my $existing_datacolumns = $self->has_object ? { map {$_->{name} => $_}  @{ $object->datacolumns } } : {};
	return [ map {
		my $new_datacolumn = $_;
		my $existing_datacolumn = $existing_datacolumns->{$new_datacolumn->{name}} // {};
		+{ %$existing_datacolumn, %$new_datacolumn }
	} grep {$_->{name}} @$rows ];
}

=head2 searchable

Get the searchable from input data

=cut

sub searchable {
	my ($self, $input_data, $data) = @_;
	my $datacolumns = $data->{datacolumns};
	return [ map {$_->{name}} grep {$_->{searchable}} @$datacolumns ];
}

=head2 get_resultset

Get the resultset to be used for creating objects

=cut

sub get_resultset {
	my $self = shift;
	return $self->schema->resultset('Jet::Basetype');
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
	return '/jet/config/basetype/' . $self->object->name;
}

=head2 edit_updated

Use the new basetype upon successful update

=cut

before 'edit_updated' => sub {
	my ($self, $validation)=@_;
	my $basetypes = $self->schema->basetypes;
	my $basetype_id = $self->object->id;
	$basetypes->{$basetype_id} = $self->object;
};


1;
