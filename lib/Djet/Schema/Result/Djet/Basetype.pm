use utf8;
package Djet::Schema::Result::Djet::Basetype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Djet::Schema::Result::Djet::Basetype - Node Base Type

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<djet.basetype>

=cut

__PACKAGE__->table("djet.basetype");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'djet.basetype_id_seq'

=head2 feature_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

References the feature table

=head2 name

  data_type: 'text'
  is_nullable: 0

Base Name - reference this in the app

=head2 title

  data_type: 'text'
  is_nullable: 0

Human readable title

=head2 parent

  data_type: 'integer[]'
  is_nullable: 1

Array of allowed parent basetypes

=head2 datacolumns

  data_type: 'json'
  default_value: '[]'
  is_nullable: 0

The column definitions

=head2 attributes

  data_type: 'json'
  default_value: '{}'
  is_nullable: 0

Basetype specific information

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

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 modified

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 created_by

  data_type: 'text'
  default_value: "current_user"()
  is_nullable: 1

=head2 modified_by

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "djet.basetype_id_seq",
  },
  "feature_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 0 },
  "parent",
  { data_type => "integer[]", is_nullable => 1 },
  "datacolumns",
  { data_type => "json", default_value => "[]", is_nullable => 0 },
  "attributes",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "searchable",
  { data_type => "text[]", is_nullable => 1 },
  "handler",
  { data_type => "text", is_nullable => 1 },
  "template",
  { data_type => "text", is_nullable => 1 },
  "created",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "modified",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "created_by",
  {
    data_type     => "text",
    default_value => \"\"current_user\"()",
    is_nullable   => 1,
  },
  "modified_by",
  { data_type => "text", is_nullable => 1 },
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

Related object: L<Djet::Schema::Result::Djet::Data>

=cut

__PACKAGE__->has_many(
  "datas",
  "Djet::Schema::Result::Djet::Data",
  { "foreign.basetype_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 feature

Type: belongs_to

Related object: L<Djet::Schema::Result::Djet::Feature>

=cut

__PACKAGE__->belongs_to(
  "feature",
  "Djet::Schema::Result::Djet::Feature",
  { id => "feature_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-02-07 04:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PcRzjPSvvGLqBLbgemG3tw

use JSON;
use Djet::NodeData::Factory;

=head2 datanodes

Type: has_many

Related object: L<Djet::Schema::Result::Djet::DataNode>

=cut

__PACKAGE__->has_many(
  "datanodes",
  "Djet::Schema::Result::Djet::DataNode",
  { "foreign.basetype_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->inflate_column('datacolumns'=>{
	inflate=>sub { JSON->new->allow_nonref->decode(shift); },
	deflate=>sub { JSON->new->allow_nonref->encode(shift); },
});

__PACKAGE__->inflate_column('attributes'=>{
	inflate=>sub { JSON->new->allow_nonref->decode(shift); },
	deflate=>sub { JSON->new->allow_nonref->encode(shift); },
});

=head1 ATTRIBUTES

=head2 engine

The Basetype class. It might take a while to build an engine, so it's cached here.

The engine meta, that is.

=cut

has engine => (
	is => 'ro',
	lazy_build => 1,
);

=head2 nodedata

The Basetype nodedata

=cut

has nodedata => (
	isa => 'Djet::NodeData',
	is => 'ro',
	lazy_build => 1,
	handles => [qw/
		dfv
	/],
);

=head1 METHODS

=head2 _build_engine

Build the handler class for the basetype

=cut

sub _build_engine {
	my $self= shift;
	my $handler = $self->handler || 'Djet::Engine::Default';
	eval "require $handler" or die $@;

	return $handler->meta->new_object;
}

=head2 _build_nodedata

Build the nodedata for the basetype.

The nodedata is built from a superclass Djet::NodeData and each field has an
attribute called __<field> and a reader called <field>.

An arrayref attribute containing fieldnames is also build.

This class is instantiated for each data or datanode requesting datacolumns from data.

=cut

sub _build_nodedata {
	my $self= shift;
	my $model = $self->result_source->schema;
	my $factory = Djet::NodeData::Factory->new(
		name => $self->name,
		model => $model,
		datacolumns => $self->datacolumns,
	);
	return $factory->nodedata_class;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT
