package Jet::Engine::Row;

use 5.010;
use Moose;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Row - Row Class for Jet::Engine

=head1 DESCRIPTION

This is the Row class for L<Jet::Engine>.

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
has 'schema'     => (
	isa => 'DBIx::Inspector::Driver::Pg',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

__END__
