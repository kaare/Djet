package Jet::Import::Iterator::Csv;

use 5.010;
use namespace::autoclean;
use Moose;
use Text::CSV;

extends 'Jet::Import::Iterator';

=head1 Description

Subclass for handling the import of a csv file

=head1 ATTRIBUTES

=head2 csv

The csv object

=cut

has 'csv' => (
	is => 'ro',
	lazy_build => 1,
);

=head1 "PRIVATE" ATTRIBUTES

=head1 METHODS

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
