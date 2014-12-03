package Jet::Data::Validator;

use 5.010;
use Moose;

use Data::FormValidator;
use Data::FormValidator::Constraints::DateTime qw/to_datetime/;
use Data::FormValidator::Constraints::MethodsFactory;

=head1 NAME

Jet::Data::Validator - basetype validator.

=head1 DESCRIPTION

This module handles the validation of nodes.

=head1 ATTRIBUTES

=head2 multi_unique

=cut

has multi_unique => (
	is => 'rw',
	isa => 'Maybe[HashRef]',
);

=head2 dfv

The user-supplied DataFormValidator profile

=cut

has dfv => (
	is => 'ro',
	isa => 'HashRef',
);

=head2 msgs

Any non-standard dfv messages

=cut

has msgs => (
	is => 'ro',
	isa => 'HashRef',
	lazy => 1,
	default => sub { {} }, 
);

=head2 profile

The DataFormValidator profile is a combination of the dfv and msgs

=cut

has profile => (
	is => 'ro',
	isa => 'HashRef',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $dfv = $self->dfv;
		$dfv->{msgs} = sub {
			$self->error_msgs(@_, $self->msgs);
		};
		return $dfv;
	},
);

=head1 METHODS

=head2 validate

Validates input against a set of rules. Add own rule 'check_empty_fields',
because Data::FormValidator discards them by default; use it to report checks against empty input too

Validate returns a Data::FormValidator::Result object.

=cut

sub validate {
	my ($self, $parameters) = @_;
	my $params = $parameters->as_hashref;
	delete $params->{save};
	my $results = Data::FormValidator->check($params, $self->profile);
	return $results;
}

=head1 METHODS

=head2 error_msgs

=cut

sub error_msgs {
	my ($self, $results) = @_;
	$results->{msgs} ||= {};

	if ($results->has_invalid) {
		my $invalids=$results->invalid;
		foreach my $field (keys %$invalids) {
			$results->{msgs}->{$field} = "$field error";
		}
	}

	if ($results->has_missing) {
		my $missings=$results->missing;
		foreach my $field (@$missings) {
			$results->{msgs}->{$field} = "$field is required";
		}
	}

	return $results->{msgs};
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

