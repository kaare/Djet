package Jet::Engine::Result;

use 5.010;
use Moose;

use Jet::Engine::Row;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Result - Result Class for Jet::Engine

=head1 DESCRIPTION

This is the Result class for L<Jet::Engine>.

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
	my $self = shift;
	my $row_data;
	state $rowno // 0; # /
	return unless $self->rows;
	$row_data = $self->rows->[$rowno++] || return;
	return $row_data if $self->raw;

	my $table_name = $row_data->{table_name} || $self->table_name;
	my $row = {
		row_data  => $row_data,
		typetable => $self->_build_typetable($row_data),
	};
	$row->{table_name} = $table_name if $table_name;
	return Jet::Engine::Row->new($row);
# Moose::Meta::Class->create_anon_class 
# then $meta->add_attribute for each column
# then cache the result of that so you don't do it again next time you run the same query
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
