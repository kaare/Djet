package Djet::NodeData::Factory;

use 5.010;
use Moose;
use namespace::sweep;

=head1 NAME

Djet::NodeData::Factory - Produce a Djet NodeData Class

=head1 DESCRIPTION

This class produces the nodedataclasses of the different basetypes, based on

	The nodedata class, default Djet::NodeData
	The nodedata role of the basetype, if any
	The datacolumns of the basetype

=head1 ATTRIBUTES

=head2 model

The Djet model

=cut

has model => (
	is => 'ro',
	isa => 'Djet::Model',
);

=head2 datacolumns

The raw data columns, an arrayref. Each array element is a hashref with the basetype id as key and the basetype row as value

=cut

has datacolumns => (
	isa => 'ArrayRef',
	is => 'ro',
);

=head2 config

The Djet configuration

=cut

has config => (
	is => 'ro',
	isa => 'Djet::Config',
	default => sub {
		my $self = shift;
		my $model = $self->model;
		return $model->config;
	},
	lazy => 1,
);

=head2 name

The basetype name

=cut

has name => (
	is => 'ro',
	isa => 'Str',
);

=head1 METHODS

=head2 nodedata_class

Creates the nodedata class

If there is a nodedata_class in the djet configuration, it will be used as the superclass. The default is 'Djet::NodeData'

Each basetype can be amended with a separate role, if

	The djet configuration parameter nodedata_roles is set
	There is a role in a file with a name looking like <nodedata_roles>::basetype
	(with all non-alphanumeric or underscore characters translated to underscore)

Furthermore, the individual columns, or fields, can be amended with traits, either by explicitely stating it in the column definition name
'traits', or by one of the standard Djet traits found in Djet::Trait::Field::<field_name>.

=cut

sub nodedata_class {
	my $self = shift;
	my $model = $self->model;
	my $config = $self->config->config;
	my %meta_params = (superclasses => [$config->{djet_config}{nodedata_class} || 'Djet::NodeData']);
	if (my $roles_prefix = $config->{djet_config}{nodedata_roles}) {
		my $basetype_name = $self->name;
		$basetype_name =~ s/[^a-zA-Z0-9_]/_/g;
		my $role_name = join '::', $roles_prefix, $basetype_name;
		eval "require $role_name" and $meta_params{roles} = [$role_name];
		unless (exists $meta_params{roles}) { # Fall back to Djet behaviour if there is no local
			$role_name = join '::', 'Djet::Part::NodeData', $basetype_name;
			eval "require $role_name" and $meta_params{roles} = [$role_name];
		}
	}
	my $meta_class = Moose::Meta::Class->create_anon_class(%meta_params);

	my $columns = $self->datacolumns;
	my @fieldnames;
	for my $column (@{ $columns }) {
		my $colname = $column->{name};
		my $coltitle = $column->{title} // ucfirst $colname;
		my $coltype = $column->{type};

		my @traits;
		@traits = ref $column->{traits} eq 'ARRAY' ? @{ $column->{traits} } : $column->{traits} if $column->{traits};
		my $fieldtraitname = "Djet::Trait::Field::$column->{type}";
		eval "require $fieldtraitname";
		push @traits, $fieldtraitname unless $@;

		push @fieldnames, $colname;
		$meta_class->add_attribute($colname => (
			is => 'ro',
			isa => 'Djet::Field',
			writer => "set_$colname",
			default => sub {
				my $self = shift;
				my $cols = $self->datacolumns; # This is the data datacolumns, NOT to be confused with the basetype datacolumns
				my %params = (
					model => $model, # The model when called from basetype
					value => $cols->{$colname},
					name => $colname,
					title => $coltitle,
					required => defined($column->{required}) && $column->{required} eq 'on',
					searchable => defined($column->{searchable}) && $column->{searchable} eq 'on',
					updatable => !defined($column->{updatable}) || defined($column->{updatable}) && $column->{updatable} eq 'on',
				);
				$params{type} = $coltype if $coltype;
				$params{default} = $column->{default} if exists $column->{default};
				$params{css_class} = $column->{css_class} if exists $column->{css_class};
				my $field = Djet::Field->with_traits(@traits)->new(%params);
				return $field;
			},
			lazy => 1,
		));
	}
	$meta_class->add_attribute(fieldnames => (
		is => 'ro',
		isa	=> 'ArrayRef[Str]',
		default => sub { \@fieldnames },
	));
	return $meta_class->new_object;
}

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__
