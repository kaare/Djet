package Djet::Field;

use 5.010;
use Moose;
use namespace::sweep;

use JSON;

with 'MooseX::Traits';

use overload
	'""' => sub { return $_[0]->value };

=head1 NAME

Djet::Field - Attributes and feature for Djet Fields

=head1 ATTRIBUTES

=head2 model

The Djet model

=cut

has 'model' => (
	is => 'ro',
	isa => 'Djet::Model',
	weak_ref => 1,
);

=head2 type

The field's type

=cut

has 'type' => (
	is => 'ro',
	isa => 'Str',
	default => 'Text',
);

=head2 name

The field's name

=cut

has 'name' => (
	is => 'ro',
	isa => 'Str',
);

=head2 title

The field's title

=cut

has 'title' => (
	is => 'ro',
	isa => 'Str',
);

=head2 value

The field's value

=cut

has 'value' => (
	is => 'ro',
	writer => '_set_value',
);

=head2 default

The field's default value

=cut

has 'default' => (
	is => 'ro',
	predicate => 'has_default',
);

=head2 link

The field's link

=cut

has 'link' => (
	is => 'ro',
	isa => 'Str',
);

=head2 required

Switch to tell if the field is required

=cut

has 'required' => (
	is => 'ro',
	isa => 'Bool',
	default => 1,
);

=head2 searchable

Switch to tell if the field is searchable

=cut

has 'searchable' => (
	is => 'ro',
	isa => 'Bool',
	default => 1,
);

=head2 updatable

Switch to tell if the field is updatable

=cut

has 'updatable' => (
	is => 'ro',
	isa => 'Bool',
	default => 1,
);

=head2 css_class

The field's css class

=cut

has 'css_class' => (
	is => 'ro',
	predicate => 'has_css_class',
);

=head1 METHODS

=head2 pack

Pack the data for storage

=cut

sub pack {
	my ($self, $value) = @_;
	return $value;
}

=head2 unpack

Unpack the data from storage

=cut

sub unpack {
	my ($self, $value) = @_;
	return $value;
}

=head2 TO_JSON

Return the field value in order for the serializer to work

=cut

sub TO_JSON {
	my $self = shift;
	return $self->value;
}

=head2 as_json

Return the field (type, title, value) as JSON

=cut

sub as_json {
	my $self = shift;
	my $hash = { map {$_ => $self->$_} qw/name type title value/ };
	return JSON->new->encode($hash);
}

=head2 for_search

Return the field value for fts

=cut

sub for_search {
	my $self = shift;
	return $self->value;
}

=head2 filters

Filters for Data::FormValidator. Default is nothing

=cut

sub filters { }

=head2 constraint_methods

Constraint Methods for Data::FormValidator. Default is nothing

=cut

sub constraint_methods { }

no Moose::Role;

1;

# COPYRIGHT

__END__
