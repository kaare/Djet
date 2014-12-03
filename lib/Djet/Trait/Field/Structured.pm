package Djet::Trait::Field::Structured;

use Moose::Role;
use YAML::Tiny;

=head1 NAME

Djet::Trait::Field::Structured

=head1 DESCRIPTION

Structured data. Input format is expected as pseudo yaml (yaml w/o the initial ---).

=cut

requires qw/value/;

=head1 ATTRIBUTES

=head2 validated_value

Value from the validation

=cut

has 'validated_value' => (
	is => 'ro',
#	isa => 'HashRef',
	writer => '_set_validated_value',
	predicate => '_has_validated_value',
);

=head1 METHODS

=head2 pack

Pack a structured field

=cut

sub pack {
	my ($self, $value) = @_;
	my $new;
	eval {$new = YAML::Tiny::Load("---\n" . $value) };
	return $@ ? $value : $new;
}

=head2 unpack

Unpack a structured field

=cut

sub unpack {
	my ($self, $value) = @_;
warn 1;
	$value //= $self->value;
	return $self->_has_validated_value ? $self->validated_value : $value;
}

=head2 constraint_methods

=cut

sub constraint_methods {
	my $self = shift;
	return $self->name => sub {
		my $dfv = shift;

        # value of 'prospective_date' parameter
        my $value = $dfv->get_current_constraint_value();

        # get other data to refer to
        my $data = $dfv->get_filtered_data;

		my $new;
		eval {$new = YAML::Tiny::Load("---\n" . $value) };
		my $error = $@;
		$self->_set_validated_value($new) unless $error;
		return !$error;
	};
}

=head2 value_for_editing

Return a structured field for editing

=cut

sub value_for_editing {
	my ($self, $value) = @_;
	$value //= $self->value;
	my $new;
	eval {$new = YAML::Tiny::Dump($value) };
	if ($@) {
		return $value;
	} else {
		$new =~ s/^---\n//m;
		return $new;
	}
}

1;
