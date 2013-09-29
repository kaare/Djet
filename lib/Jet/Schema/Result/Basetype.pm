use utf8;
package Jet::Schema::Result::Basetype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Jet::Schema::Result::Basetype - Node Base Type

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

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


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-29 13:35:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OHW02/bWrThD8MHvcHJiXg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
