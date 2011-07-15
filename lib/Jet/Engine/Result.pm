package Jet::Engine::Iterator;

use Moose;
use Carp ();

=head1 Attributes

=head2 raw

Set row object creation mode.

NB! Default is true, until the expansion actually works

=cut

has 'raw' => (isa => 'Bool', is => 'rw', default => 1);
has 'sth' => (isa => 'DBI::st', is => 'ro');

sub next {
    my $self = shift;
    my $row;
    if ($self->sth) {
        $row = $self->sth->fetchrow_hashref('NAME_lc');
        unless ( $row ) {
            $self->sth->finish;
#!!            $self->sth = undef;
            return;
        }
    } else {
        return;
    }

    if ($self->raw) {
        return $row;
    } else {
        return $self->row_class->new(
            {
                sql        => $self->{sql},
                row_data   => $row,
                'Jet::Engine'       => $self->{'Jet::Engine'},
                table_name => $self->table_name,
            }
        );
    }
}

sub all {
    my $self = shift;
    my @result;
    while ( my $row = $self->next ) {
        push @result, $row;
    }
    return wantarray ? @result : \@result;
}

1;

__END__
=head1 NAME

Jet::Engine::Iterator - Iterator for Jet::Engine

=head1 DESCRIPTION

This is an iterator class for L<Jet::Engine>.

=head1 SYNOPSIS

  my $itr = Your::Model->search('user',{});
  
  my @rows = $itr->all; # get all rows

  # do iteration
  while (my $row = $itr->next) {
    ...
  }

=head1 METHODS

=over

=item $itr = Jet::Engine::Iterator->new()

Create new Jet::Engine::Iterator's object. You may not call this method directly.

=item my $row = $itr->next();

Get next row data.

=item my @ary = $itr->all;

Get all row data in array.


=cut

