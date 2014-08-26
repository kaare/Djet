package Jet::Role::DB::Result::Data;

use 5.010;
use Moose::Role;
use namespace::autoclean;
use vars qw($AUTOLOAD);

=head1 NAME

Jet::Role::DB::Result::Data

=head1 DESCRIPTION

Common methods for data and datanodes.

=cut

=head2 field_inflate

Specific inflating for each field

=cut

sub field_inflate {
	my ($self, $data) = @_;
	my $fields = $self->datacolumns;
	while (my ($name, $value) = each %$data) {
		die "No field $name for datanode " . $self->id unless my $field = $fields->can($name);

		$data->{$name} = $fields->$field->unpack($value);
	}
}

=head1 ATTRIBUTES

=head2 fields

Fields is a Jet::Fields filled with the datacolumns data

=cut

has 'fields' => (
	is => 'ro',
	isa => 'Jet::Fields',
	lazy_build => 1,
);

sub _build_fields {
	my $self= shift;
	return $self->basetype->fields->new( datacolumns =>  $self->datacolumns );
}

=head2 field_deflate

Specific deflating for each field

=cut

sub field_deflate {
	my ($self, $datacol) = @_;
	my $fields = $self->datacolumns;
	while (my ($name, $value) = each %$datacol) {
		die "No field $name for datanode " . $self->id unless my $field = $fields->can($name);

		$datacol->{$name} = $fields->$field->pack($value);
	}
}

=head2 update_fts

Update the fts columns with the relevant data from fields

=cut

sub update_fts {
	my ($self, $datacol) = @_;
	# jet.basetype
	my $basetype = $self->basetype;

	my $fts = $self->title;
	for my $field (@{ $self->fields->fields }) {
		next unless $field->searchable;

		$fts .= ' ' . $field->for_search;
	}

	$fts =~ s/[,-\/:)(']/ /g;
	$fts = lc $fts;
	my $q = qq{to_tsvector('danish', '$fts')};
	$self->update({fts => \$q });
}

=head2 autoload

Method calls are checked to see if they match a JSON column. If so, they're handled as ordinary accessors

=cut

sub AUTOLOAD {
	my $self = shift;
	$AUTOLOAD =~ /::(\w+)$/;
	my $method = $1;
	return if $method eq 'fields';

	my $fields = $self->fields or return;
	die "No field $method for datanode " . $self->id unless my $field = $fields->can($method);

	return $fields->$field(@_);
}

no Moose::Role;

1;

# COPYRIGHT

__END__
