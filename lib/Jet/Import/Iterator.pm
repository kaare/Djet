package Jet::Import::Iterator;

use 5.010;
use namespace::autoclean;
use Moose;

=head1 Description

Base class for handling the import of a csv file

=head1 ATTRIBUTES

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

=head2 file_name

The name of the import file

=cut

has file_name => (
	is => 'ro',
	isa => 'Str',
);

=head1 "PRIVATE" ATTRIBUTES

=head2 file

The import file

=cut

has 'file' => (
	is => 'ro',
	lazy_build => 1,
);

=head1 METHODS

=head2 _build_file

The lazy builder for the file

The base class opens a file as UTF-8 and returns it.

=cut

sub _build_file {
	my $self = shift;
	my $filename = $self->file_name;
	open(my $file, "<:encoding(UTF-8)", $filename) or die "$filename: $!";

	return $file;
}

=head2 next

Return the next row of data from the file

=cut

sub next {
	return 'should be sub classed';
}

1;

# COPYRIGHT
