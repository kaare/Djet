use utf8;
package Djet::Schema::Result::Djet::Cart;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Djet::Schema::Result::Djet::Cart

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

=head1 TABLE: C<jet.carts>

=cut

__PACKAGE__->table("jet.carts");

=head1 ACCESSORS

=head2 code

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'jet.carts_code_seq'

=head2 name

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 uid

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 session_id

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 created

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 last_modified

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 type

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 approved

  data_type: 'boolean'
  is_nullable: 1

=head2 status

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "code",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "jet.carts_code_seq",
  },
  "name",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "uid",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "session_id",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "created",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "last_modified",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "type",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "approved",
  { data_type => "boolean", is_nullable => 1 },
  "status",
  { data_type => "text", default_value => "", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("code");

=head1 RELATIONS

=head2 cart_products

Type: has_many

Related object: L<Djet::Schema::Result::Djet::CartProduct>

=cut

__PACKAGE__->has_many(
  "cart_products",
  "Djet::Schema::Result::Djet::CartProduct",
  { "foreign.cart" => "self.code" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-10-17 13:09:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uSb13dhuYT+0DqNNZSSLxA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
