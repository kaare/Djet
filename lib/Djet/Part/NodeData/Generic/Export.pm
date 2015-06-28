package Djet::Part::NodeData::Generic::Export;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::NodeData::Generic::Export

=head1 SYNOPSIS

with 'Djet::Part::NodeData::Generic::Export';

=head1 DESCRIPTION

This export functionality relies on there being an "export" attribute on the node, listing all of
the fields to be exported.

An example export attribute could be

	name description price

name and description could be ordinary fields on the node, and price could need special care for exporting. In the NodeData class there would be a method like

sub export_price {
	my $self = shift;
	return $self->price * 2;
}

=head1 ATTRIBUTES

=head2 export

Returns the data for exporting to a file as an arrayref

Field names are taken from the basetype attribute called "export".

 - If there is a method called "export_$field_name", this will be used.
 - If there is a field with that name, the value of that field is used.
 - Otherwise an empty string is returned.

=cut

has 'export' => (
	is => 'ro',
	isa => 'ArrayRef',
	default => sub {
		my $self = shift;
		my $prod_type = $self->node->basetype or return [];
		my @export_fields = split '\s+', $prod_type->attributes->{export} or return [];

		my @export = map {
			my $field_name = $_;
			my $export_name = "export_$field_name";
			$self->can($export_name) ? $self->$export_name
				: $self->can($field_name) ?  $self->$field_name->value : ''
		} @export_fields;
		return \@export;
	},
	lazy => 1,
);

no Moose::Role;

1;

# COPYRIGHT

__END__
