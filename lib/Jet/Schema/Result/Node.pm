use utf8;
package Jet::Schema::Result::Node;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Jet::Schema::Result::Node - Node

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<jet.node>

=cut

__PACKAGE__->table("jet.node");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'jet.node_id_seq'

=head2 data_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 parent_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

Parent of this uri

=head2 part

  data_type: 'text'
  is_nullable: 1

Path part

=head2 node_path

  data_type: 'prefix_range'
  is_nullable: 1

Global Path parts

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
    sequence          => "jet.node_id_seq",
  },
  "data_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "parent_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "part",
  { data_type => "text", is_nullable => 1 },
  "node_path",
  { data_type => "prefix_range", is_nullable => 1 },
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

=head1 RELATIONS

=head2 data

Type: belongs_to

Related object: L<Jet::Schema::Result::Data>

=cut

__PACKAGE__->belongs_to(
  "data",
  "Jet::Schema::Result::Data",
  { id => "data_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 nodes

Type: has_many

Related object: L<Jet::Schema::Result::Node>

=cut

__PACKAGE__->has_many(
  "nodes",
  "Jet::Schema::Result::Node",
  { "foreign.parent_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<Jet::Schema::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Jet::Schema::Result::Node",
  { id => "parent_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-03 11:41:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DrIASJM1AHye6F+ZzRge9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
