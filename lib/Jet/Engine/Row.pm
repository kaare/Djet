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
	isa => 'HashRef',
	is => 'ro',
);
has 'table_name' => (isa => 'Str', is => 'ro');
has 'schema'     => (
    isa => 'DBIx::Inspector::Driver::Pg',
    is => 'ro',
);

sub get_column {
    my ($self, $col) = @_;

    unless ( $col ) {
        Carp::croak('please specify $col for first argument');
    }

    if ( exists $self->{row_data}->{$col} ) {
        return $self->{row_data}->{$col};
    } else {
        Carp::croak("Specified colum '$col' not found in row (query: " . ( $self->{sql} || 'unknown' ) . ")" );
    }
}

__PACKAGE__->meta->make_immutable;

__END__
