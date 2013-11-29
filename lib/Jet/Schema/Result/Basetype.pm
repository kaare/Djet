use utf8;
package Jet::Schema::Result::Basetype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Jet::Schema::Result::Basetype - Node Base Type

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<jet.basetype>

=cut

__PACKAGE__->table("jet.basetype");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'jet.basetype_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 1

Base Name

=head2 parent

  data_type: 'integer[]'
  is_nullable: 1

Array of allowed parent basetypes

=head2 datacolumns

  data_type: 'json'
  is_nullable: 1

The column definitions

=head2 searchable

  data_type: 'text[]'
  is_nullable: 1

The searchable columns

=head2 handler

  data_type: 'text'
  is_nullable: 1

The handler module

=head2 template

  data_type: 'text'
  is_nullable: 1

The template for this basetype

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 modified

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "jet.basetype_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 1 },
  "parent",
  { data_type => "integer[]", is_nullable => 1 },
  "datacolumns",
  { data_type => "json", is_nullable => 1 },
  "searchable",
  { data_type => "text[]", is_nullable => 1 },
  "handler",
  { data_type => "text", is_nullable => 1 },
  "template",
  { data_type => "text", is_nullable => 1 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "modified",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<basetype_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("basetype_name_key", ["name"]);

=head1 RELATIONS

=head2 datas

Type: has_many

Related object: L<Jet::Schema::Result::Data>

=cut

__PACKAGE__->has_many(
  "datas",
  "Jet::Schema::Result::Data",
  { "foreign.basetype_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-03 11:41:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PFlTCwB6RSlL1XdEDQpxwQ

use Moose;

=head1 ATTRIBUTES

=head2 class

The Basetype class

=cut

has class => (
	isa => 'Jet::Engine::Runtime',
	is => 'ro',
	lazy_build => 1,
);

=head2 fields

The Basetype fields

=cut

has fields => (
	isa => 'Jet::Fields',
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

=head2 _build_fields

Build the fields for the basetype

=cut

sub _build_fields {
	my $self= shift;
	my $meta_class = Moose::Meta::Class->create_anon_class(superclasses => ['Jet::Fields']);
	my $colidx;
	my $columns = $self->datacolumns;
	my @fieldcols;
	for my $column (@{ $columns }) {
		my $colname = $column->{name};
		my $coltype = $column->{type};
		my $traits =  $column->{traits};
		$meta_class->add_attribute("__$colname" => (
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
	}
	return $meta_class->new_object;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;

# COPYRIGHT

__END__
