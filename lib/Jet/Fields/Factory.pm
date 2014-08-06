package Jet::Fields::Factory;

use 5.010;
use Moose;
use namespace::sweep;

=head1 NAME

Jet::Fields::Factory - Produce a Jet Fields Class

=head1 SYNOPSIS

This class probably only makes sense for the Jet system itself

=head1 ATTRIBUTES

=head2 datacolumns

The raw data columns, an arrayref. Each array element is a hashref containing

=over 4

=item * name (Required)

=item * title (Required)

=item * type (Required)

=item * traits (Optional)

=back

=cut

has datacolumns => (
	isa => 'ArrayRef',
	is => 'ro',
);

=head1 METHODS

=head2 fields_class

Creates the fields class

=cut

sub fields_class {
	my $self = shift;
	my $meta_class = Moose::Meta::Class->create_anon_class(superclasses => ['Jet::Fields']);
	my $columns = $self->datacolumns;
	my @fieldnames;
	for my $column (@{ $columns }) {
		my $colname = $column->{name};
		my $coltitle = $column->{title};
		my $coltype = $column->{type};

		my $traits = !$column->{traits} || ref $column->{traits} eq 'ARRAY' ? $column->{traits} : [ $column->{traits} ];
		my $fieldtraitname = "Jet::Trait::Field::$column->{type}";
		eval "require $fieldtraitname";
		push @$traits, $fieldtraitname unless $@;

		push @fieldnames, $colname;
		$meta_class->add_attribute($colname => (
			is => 'ro',
			isa => 'Jet::Field',
			writer => "set_$colname",
			default => sub {
				my $self = shift;
				my $cols = $self->datacolumns;
				my %params = (
					value => $cols->{$colname},
					name => $colname,
					title => $coltitle,
				);
				$params{type} = $coltype if $coltype;
				return $traits ?
					Jet::Field->with_traits(@$traits)->new(%params) :
					Jet::Field->new(%params);
			},
			lazy => 1,
		));
	}
	$meta_class->add_attribute(fieldnames => (
		is => 'ro',
		isa	=> 'ArrayRef[Str]',
		default => sub { \@fieldnames },
	));
	return $meta_class->new_object;
}

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__
