use utf8;
package Djet::Schema::Result::Djet::Feature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Djet::Schema::Result::Djet::Feature

=head1 DESCRIPTION

A feature is a collection of basetypes that forms or supports a set of functions or methods

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

=head1 TABLE: C<djet.feature>

=cut

__PACKAGE__->table("djet.feature");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'djet.feature_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

Feature Name

=head2 version

  data_type: 'numeric'
  is_nullable: 1

Feature Version

=head2 description

  data_type: 'text'
  is_nullable: 1

Feature Description

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 modified

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_by

  data_type: 'text'
  default_value: "current_user"()
  is_nullable: 1

The user (role) name that created the feature

=head2 modified_by

  data_type: 'text'
  is_nullable: 1

The user (role) name that modified the feature last

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "djet.feature_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "version",
  { data_type => "numeric", is_nullable => 1 },
  "description",
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

=head2 C<feature_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("feature_name_key", ["name"]);

=head1 RELATIONS

=head2 basetypes

Type: has_many

Related object: L<Djet::Schema::Result::Djet::Basetype>

=cut

__PACKAGE__->has_many(
  "basetypes",
  "Djet::Schema::Result::Djet::Basetype",
  { "foreign.feature_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-02-07 04:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NYg7IIJwNl98MM2ekDuq4A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
