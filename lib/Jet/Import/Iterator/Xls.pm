package Jet::Import::Iterator::Xls;

use 5.010;
use namespace::autoclean;
use Moose;
use Spreadsheet::ParseExcel;

extends 'Jet::Import::Iterator';

=head1 Description

Subclass for handling the import of an excel file

=head1 ATTRIBUTES

=head2 excel

The excel object

=cut

has 'excel' => (
	is => 'ro',
	lazy_build => 1,
);

=head2 sheet

The sheet name or number

=cut

has sheet => (
	is => 'ro',
	isa => 'Str',
	default => 0,
);

=head1 "PRIVATE" ATTRIBUTES

=head2 column_names

The column names

=cut

has column_names => (
	is => 'rw',
	isa => 'ArrayRef',
	predicate => 'has_column_names',
);

=head1 METHODS

=head2 _build_excel

The lazy builder for the excel object

=cut

sub _build_excel {
	my $self = shift;
	my $table = Spreadsheet::ParseExcel->new()
		->parse($self->file_name)
		->worksheet($self->sheet);
	return $table;
}

=head2 next

Return the next row of data from the file

=cut

sub next {
	my $self = shift;
	my $xls = $self->excel;
	state $rc = [$xls->row_range];
	state $cc = [$xls->col_range];
	# Use the first row as column names:
	if (!$self->has_column_names) {
		my @fieldnames = map {my $header = lc $_; $header =~ tr/ /_/; $header} $self->get_row_values($xls, @$cc);
		die "Only one column detected, please use comma ',' to separate data." if @fieldnames < 2;

		$self->column_names(\@fieldnames);
	}
	$self->inc_lineno;

	return if grep {!defined $xls->get_cell($self->lineno, $_)} ($cc->[0]..$cc->[1]);
	return $self->get_row($xls, @$cc);
}

sub get_row_values {
	my ($self, $xls, $from, $to) = @_;
	my @cells;
	push @cells, $xls->get_cell($self->lineno, $_)->value for $from..$to;
	return @cells;
}

sub get_row {
	my ($self, $xls, $from, $to) = @_;
	my $colnames = $self->column_names;
	my %cells;
	$cells{ $colnames->[$_ - $from] } = $xls->get_cell($self->lineno, $_)->value for $from..$to;
	return \%cells;
}
1;

# COPYRIGHT
