package Djet::NodeData::Factory;

use 5.010;
use Moose;
use namespace::sweep;

=head1 NAME

Djet::NodeData::Factory - Produce a Djet NodeData Class

=head1 DESCRIPTION

This class produces the nodedataclasses of the different basetypes, based on

	The nodedata class, default Djet::NodeData
	The nodedata role of the basetype
	The datacolumns of the basetype

=head1 ATTRIBUTES

=head2 datacolumns

The raw data columns, an arrayref. Each array element is a hashref with the basetype id as key and the basetype row as value

=cut

has datacolumns => (
	isa => 'ArrayRef',
	is => 'ro',
);

=head2 config

The Djet configuration

=cut

has config => (
	is => 'rw',
	isa => 'Djet::Config',
);

=head1 METHODS

=head2 nodedata_class

Creates the nodedata class

=cut

sub nodedata_class {
	my $self = shift;
	my $meta_class = Moose::Meta::Class->create_anon_class(superclasses => ['Djet::NodeData']);
	my $columns = $self->datacolumns;
	my @fieldnames;
	for my $column (@{ $columns }) {
		my $colname = $column->{name};
		my $coltitle = $column->{title} // ucfirst $colname;
		my $coltype = $column->{type};

		my $traits = !$column->{traits} || ref $column->{traits} eq 'ARRAY' ? $column->{traits} : [ $column->{traits} ];
		my $fieldtraitname = "Djet::Trait::Field::$column->{type}";
		eval "require $fieldtraitname";
		push @$traits, $fieldtraitname unless $@;

		push @fieldnames, $colname;
		$meta_class->add_attribute($colname => (
			is => 'ro',
			isa => 'Djet::Field',
			writer => "set_$colname",
			default => sub {
				my $self = shift;
				my $cols = $self->datacolumns; # This is the data datacolumns, NOT to be confused with the basetype datacolumns
				my %params = (
					value => $cols->{$colname},
					name => $colname,
					title => $coltitle,
					required => defined($column->{required}) && $column->{required} eq 'on',
					searchable => defined($column->{searchable}) && $column->{searchable} eq 'on',
				);
				$params{type} = $coltype if $coltype;
				$params{default} = $column->{default} if exists $column->{default};
				$params{css_class} = $column->{css_class} if exists $column->{css_class};
				return $traits ?
					Djet::Field->with_traits(@$traits)->new(%params) :
					Djet::Field->new(%params);
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
