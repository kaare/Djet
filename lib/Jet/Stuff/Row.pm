package Jet::Stuff::Row;

use 5.010;
use Moose;

with 'Jet::Role::Log';

=head1 NAME

Jet::Stuff::Row - Row Class for Jet::Stuff

=head1 DESCRIPTION

This is the Row class for L<Jet::Stuff>.

=head1 SYNOPSIS

  my $row = Your::Model->search('user',{})->result->next;
  
=head1 METHODS

=over

=item my $row = $row->next();

Get next row data.

=item my @ary = $row->all;

Get all row data in array.

=head1 Attributes

=cut

has 'row_data' => (
	traits    => ['Hash'],
	is        => 'ro',
	isa       => 'HashRef',
	default   => sub { {} },
	handles   => {
		set_column     => 'set',
		get_column     => 'get',
		has_no_columns => 'is_empty',
		num_columns    => 'count',
		delete_column  => 'delete',
		get_columns    => 'kv',
	},
);
has 'table_name' => (isa => 'Str', is => 'ro');
has 'typetable'     => (
	isa => 'HashRef',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

__END__
