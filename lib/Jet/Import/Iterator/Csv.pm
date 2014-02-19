package Jet::Import::Iterator::Csv;

use 5.010;
use namespace::autoclean;
use Moose;
use Text::CSV;

# extends 'Jet::Import::Iterator';

=head1 Description

Role for handling the import of a csv file

=head1 ATTRIBUTES

=head2 csv

The csv object

=cut

has 'csv' => (
	is => 'ro',
	lazy_build => 1,
);

=head2 lineno

The line counter

=cut

has 'lineno' => (
	is => 'ro',
	isa => 'Num',
	traits => ['Counter'],
	default => 0,
	handles => {
		inc_lineno => 'inc',
		reset_lineno => 'reset',
	},
);

=head1 "PRIVATE" ATTRIBUTES

=head2 file

The csv file

=cut

has 'file' => (
	is => 'ro',
	writer => '_set_file',
	lazy_build => 1,
);

=head2 file_name

The name of the spreadsheet

=cut

has file_name => (
	is => 'ro',
	isa => 'Str',
);

=head1 METHODS

=head2 _build_file

The lazy builder for the file

=cut

sub _build_file {
	my $self = shift;
	my $filename = $self->file_name;
	open(my $file, "<:encoding(UTF-8)", $filename) or die "$filename: $!";

	return $file;
}

=head2 _build_csv

The lazy builder for the csv object

=cut

sub _build_csv {
	my $self = shift;
	my $csv = Text::CSV->new ({ binary => 1, eol => $/ });
	return $csv;
}

=head2 next

Return the next row of data from the file

=cut

sub next {
	my $self = shift;
	my $file = $self->file;
	my $csv = $self->csv;
	# Use the first row as column names:
	if (!$csv->column_names) {
		my $row = $csv->getline($file);
		my @fieldnames = map {my $header = lc $_; $header =~ tr/ /_/; $header} $csv->fields;
		die "Only one column detected, please use comma ',' to separate data." if @fieldnames < 2;

		$csv->column_names(@fieldnames);
	}
	$self->inc_lineno;
    return $csv->getline_hr($file);
}

1;

# COPYRIGHT
