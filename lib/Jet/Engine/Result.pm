package Jet::Engine::Result;

use 5.010;
use Moose;

use Jet::Engine::Row;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Result - Result Class for Jet::Engine

=head1 DESCRIPTION

This is the Result class for L<Jet::Engine>.

=head1 SYNOPSIS

  my $result = Your::Model->search('user',{});
  
  my @rows = $result->all; # get all rows

  # do iteration
  while (my $row = $result->next) {
    ...
  }

=head1 METHODS

=over

=item my $row = $result->next();

Get next row data.

=item my @ary = $result->all;

Get all row data in array.

=head1 Attributes

=head2 raw

Set row object creation mode.

NB! Default is true, until the expansion actually works

=cut

has 'raw'        => (isa => 'Bool', is => 'rw', default => 0);
has 'sth'        => (isa => 'DBI::st', is => 'ro');
has 'table_name' => (isa => 'Str', is => 'ro');
has 'schema'     => (
	isa => 'DBIx::Inspector::Driver::Pg',
	is => 'ro',
);

sub next {
	my $self = shift;
	my $row;
	if ($self->sth) {
		$row = $self->sth->fetchrow_hashref('NAME_lc');
		unless ( $row ) {
			$self->sth->finish;
#!!			$self->sth = undef;
			return;
		}
	} else {
		return;
	}

	return $self->raw ?
		$row :
		Jet::Engine::Row->new({
#			sql        => $self->{sql},
			row_data   => $row,
#			'Jet::Engine'       => $self->{'Jet::Engine'},
			table_name => $self->table_name,
			typetable => $self->_build_typetable($row),
# Moose::Meta::Class->create_anon_class 
# then $meta->add_attribute for each column
# then cache the result of that so you don't do it again next time you run the same query?
		}
	);
}

sub _build_typetable {
	my ($self, $row) = @_;
return {};
	# my @columns = $self->schema->table($self->table_name)->columns;
	# return { map {$_->name => $_} grep {defined $row->{$_->name} } @columns };
}

sub all {
	my $self = shift;
	my @result;
	while ( my $row = $self->next ) {
		push @result, $row;
	}
	return wantarray ? @result : \@result;
}

__PACKAGE__->meta->make_immutable;

__END__
