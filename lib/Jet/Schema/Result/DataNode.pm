use utf8;
package Jet::Schema::Result::DataNode;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Jet::Schema::Result::DataNode

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<data_node>

=cut

__PACKAGE__->table("data_node");

=head1 ACCESSORS

=head2 data_id

  data_type: 'integer'
  is_nullable: 1

=head2 basetype_id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 datacolumns

  data_type: 'text[]'
  is_nullable: 1

=head2 fts

  data_type: 'tsvector'
  is_nullable: 1

=head2 data_created

  data_type: 'timestamp'
  is_nullable: 1

=head2 data_modified

  data_type: 'timestamp'
  is_nullable: 1

=head2 node_id

  data_type: 'integer'
  is_nullable: 1

=head2 parent_id

  data_type: 'integer'
  is_nullable: 1

=head2 part

  data_type: 'text'
  is_nullable: 1

=head2 node_path

  data_type: 'text'
  is_nullable: 1

=head2 node_created

  data_type: 'timestamp'
  is_nullable: 1

=head2 node_modified

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "data_id",
  { data_type => "integer", is_nullable => 1 },
  "basetype_id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "datacolumns",
  { data_type => "text[]", is_nullable => 1 },
  "fts",
  { data_type => "tsvector", is_nullable => 1 },
  "data_created",
  { data_type => "timestamp", is_nullable => 1 },
  "data_modified",
  { data_type => "timestamp", is_nullable => 1 },
  "node_id",
  { data_type => "integer", is_nullable => 1 },
  "parent_id",
  { data_type => "integer", is_nullable => 1 },
  "part",
  { data_type => "text", is_nullable => 1 },
  "node_path",
  { data_type => "text", is_nullable => 1 },
  "node_created",
  { data_type => "timestamp", is_nullable => 1 },
  "node_modified",
  { data_type => "timestamp", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-03 13:46:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fJXHmM94a1ae7Wunkp2KhQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
