package Jet::Stuff::Result;

use 5.010;
use Moose;

use Jet::Stuff::Row;

with 'Jet::Role::Log';

=head1 NAME

Jet::Stuff::Result - Result Class for Jet::Stuff

=head1 DESCRIPTION

This is the Result class for L<Jet::Stuff>.

Rows in a result set can be of different types. If table_name is given it is regardes as a default

=head1 SYNOPSIS

  my $result = Your::Model->search('user',{});
  
  my @rows = $result->all; # get all rows

  # do iteration
  while (my $row = $result->next) {
    ...
  }

=head1 Attributes

=head2 raw

Set row object creation mode.

=cut

has 'raw'        => (isa => 'Bool', is => 'rw', default => 0);
has 'rows'        => (isa => 'ArrayRef', is => 'ro');
has 'rowno' => (
	traits  => ['Counter'],
	is      => 'ro',
	isa     => 'Num',
	default => 0,
	handles => {
		inc_rowno   => 'inc',
		dec_rowno   => 'dec',
		reset_rowno => 'reset',
	},
);
has 'table_name' => (isa => 'Str', is => 'ro');
has 'schema'     => (
	isa => 'DBIx::Inspector::Driver::Pg',
	is => 'ro',
);

=head1 METHODS

=over

=head2 _build_typetable

Build the table of types necessary to make the column expansion methods

=cut

sub _build_typetable {
	my ($self, $row) = @_;
return {};
	# my @columns = $self->schema->table($self->table_name)->columns;
	# return { map {$_->name => $_} grep {defined $row->{$_->name} } @columns };
}

=head2 my $row = $result->next();

Get next row data.

=cut

sub next {
	my ($self, $wanted) = @_;
	my $row_data;
	return unless $self->rows;

	$row_data = $self->rows->[$self->rowno] || return;
	$self->inc_rowno;
	return $row_data if $self->raw;

	my $table_name = $row_data->{table_name} || $self->table_name;
	my $row_hash = {
		row_data  => $row_data,
		typetable => $self->_build_typetable($row_data),
	};
	$row_hash->{table_name} = $table_name if $table_name;
	my $row = Jet::Stuff::Row->new($row_hash);
	return Jet::Node->new(
		row  => $row,
	) if $wanted;
# XXX
	return $row;
}

=head2 my @ary = $result->all;

Get all row data in array.

=cut

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
