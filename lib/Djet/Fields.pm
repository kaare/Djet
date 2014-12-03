package Djet::Fields;

use 5.010;
use Moose;
use namespace::autoclean;

use JSON;

use Djet::Field;

=head1 NAME

Djet::Fields - Djet Fields Base Class

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 datacolumns

The raw data columns

=cut

has datacolumns => (
	isa => 'HashRef',
	is => 'ro',
);

=head2 fields

Returns an arrayref with all the fields

=cut

has fields => (
	is => 'ro',
	isa	 => 'ArrayRef[Djet::Field]',
	default => sub {
		my $self = shift;
		return [ map { $self->$_  } @{ $self->fieldnames } ];
	},
	lazy => 1,
);

=head2 dfv

The Data::Form::Validator init hashref for the basetype

=cut

has dfv => (
	isa => 'HashRef',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $dfv = {
			required => $self->required,
			optional => $self->optional,
			filters  => 'trim',
			field_filters => $self->field_filters,
			constraint_methods => $self->constraint_methods,
		};
		return $dfv;
	},
	writer => 'set_dfv',
);

=head1 METHODS

=head2 fields_as_json

Return the fields (type, title, value) as JSON

=cut

sub fields_as_json {
	my $self = shift;
	return [ map { $_->as_json } @{ $self->fields } ];
}

=head2 required

Return an arrayref containing the names of the required fields

=cut

sub required {
	my $self = shift;
	return [ map { $_->name } grep { $_->required } @{ $self->fields } ];
}

=head2 optional

Return an arrayref containing the names of the optional (non required) fields

=cut

sub optional {
	my $self = shift;
	return [ map { $_->name } grep { !$_->required } @{ $self->fields } ];
}

=head2 field_filters

Return an arrayref containing the field_filters for all fields

=cut

sub field_filters {
	my $self = shift;
	return { map { $_->filters } @{ $self->fields } };
}

=head2 constraint_methods

Return an arrayref containing the constraint_methods for alle fields

=cut

sub constraint_methods {
	my $self = shift;
	return { map {$_->constraint_methods } @{ $self->fields } };
}

=head2 values

Return a hashref containing the values of the fields

=cut

sub values {
	my $self = shift;
	return { map { $_->name => $_->value }  @{ $self->fields } };
}

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__
