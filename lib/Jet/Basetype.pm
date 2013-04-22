package Jet::Basetype;

use 5.010;
use Moose;
use JSON;

use Jet::Field;

with 'Jet::Role::Log';

=head1 NAME

Jet::Basetype - Jet Basetype Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engine basetypes.

=head1 ATTRIBUTES

=head3 basetype

The basetype columns

=head3 class

The basetype handler class

=cut

has basetype => (
	isa => 'HashRef',
	is => 'ro',
);
has class => (
	isa => 'Moose::Meta::Role',
	is => 'ro',
	lazy_build => 1,
);

=head1 METHODS

=head2 _build_class

Build the handler class for the basetype

=cut

sub _build_class {
	my $self= shift;
}

=head2 _build_field

=cut

sub _build_field {
	my $self= shift;
	my $role = Moose::Meta::Role->create_anon_role;
	my $colidx;
	my $columns = $self->basetype->{columns};
	my @fieldcols;
	for my $column (@{ $columns }) {
		my $colname = $column->{name};
		my $coltype = $column->{type};
		my $traits =  $column->{traits};
		$role->add_attribute("__$colname" => (
			reader  => "get_$colname",
			isa     => 'Jet::Field',
			default => sub {
				my $self = shift;
				my $cols = $self->get_column('columns');
				my %params = (
					value => $cols->[$colidx++],
					title => $colname,
					node  => $self,
				);
				return $traits ?
					Jet::Field->with_traits(@$traits)->new(%params) :
					Jet::Field->new(%params);
			},
			lazy => 1,
		));
		push @fieldcols, "get_$colname";
	}
	$role->add_attribute('fields' => (
		is => 'ro',
		isa => 'ArrayRef',
		default => sub {
			my $self = shift;
			return [ map {$self->$_} @fieldcols ];
		},
		lazy => 1,
	));
	return $role;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

