use utf8;
package Jet::Schema::Result::Jet::Data;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Jet::Schema::Result::Jet::Data - Data

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

=head1 TABLE: C<jet.data>

=cut

__PACKAGE__->table("jet.data");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'jet.data_id_seq'

=head2 basetype_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

The Basetype of the Data

=head2 name

  data_type: 'text'
  is_nullable: 0

The name

=head2 title

  data_type: 'text'
  is_nullable: 0

The Title

=head2 datacolumns

  data_type: 'json'
  default_value: '{}'
  is_nullable: 0

The actual column data

=head2 acl

  data_type: 'json'
  default_value: '{}'
  is_nullable: 0

=head2 fts

  data_type: 'tsvector'
  is_nullable: 1

Full Text Search column containing the content of the searchable columns

=head2 created

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 modified

  data_type: 'timestamp with time zone'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "jet.data_id_seq",
  },
  "basetype_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 0 },
  "datacolumns",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "acl",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "fts",
  { data_type => "tsvector", is_nullable => 1 },
  "created",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "modified",
  { data_type => "timestamp with time zone", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 basetype

Type: belongs_to

Related object: L<Jet::Schema::Result::Jet::Basetype>

=cut

__PACKAGE__->belongs_to(
  "basetype",
  "Jet::Schema::Result::Jet::Basetype",
  { id => "basetype_id" },
  { is_deferrable => 0, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 nodes

Type: has_many

Related object: L<Jet::Schema::Result::Jet::Node>

=cut

__PACKAGE__->has_many(
  "nodes",
  "Jet::Schema::Result::Jet::Node",
  { "foreign.data_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-09-17 16:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FrlCm3OI65AUa78HAesgPg

use JSON;

=head1 JSON column handling

=head2 inflate datacolumns

The JSON columns are stored in the datacolumns database column and is autoinflated upon request.

As a side-effect it updates the fts column with the relevant data from datacolumns

=cut

has 'json' => (
	is => 'ro',
	isa => 'JSON',
	default => sub { JSON->new },
	lazy => 1,
);

__PACKAGE__->inflate_column('datacolumns'=>{
	inflate=>sub { JSON->new->allow_nonref->decode(shift); },
	deflate=>sub { JSON->new->allow_nonref->encode($a); },
});

with qw/
	Jet::Role::DB::Result::Data
/;

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT
