package Jet::Basetype;

use 5.010;
use Moose;
use namespace::autoclean;

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

my @db_columns = qw/
	datacolumns
	handler
	searchable
	template
/;

has basetype => (
	isa => 'HashRef',
	is => 'ro',
	traits    => ['Hash'],
	handles => {
		map {$_ => [get => $_]} @db_columns,
	},
);
has class => (
	isa => 'Jet::Engine::Runtime',
	is => 'ro',
	lazy_build => 1,
);

=head1 METHODS

=head2 _build_class

Build the handler class for the basetype

=cut

sub _build_class {
	my $self= shift;
	my $handler = $self->handler || 'Jet::Engine::Default';
	my $meta_class = Moose::Meta::Class->create('Jet::Engine::Runtime',superclasses => [$handler]);
	return $meta_class->new_object;
}

=head2 _build_field

=cut

sub _build_field {
	my $self= shift;
	my $role = Moose::Meta::Role->create_anon_role;
	my $colidx;
	my $columns = $self->basetype->{datacolumns};
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
				my $cols = $self->get_column('datacolumns');
				my %params = (
					value => $cols->[$colidx++],
					title => $colname,
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

# COPYRIGHT

__END__
