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

=head1 TABLE: C<djet.carts>

=cut

__PACKAGE__->table("djet.carts");

=head1 ACCESSORS

=head2 code

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'djet.carts_code_seq'

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

=head2 order_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

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
    sequence          => "djet.carts_code_seq",
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
  "order_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

=head2 order

Type: belongs_to

Related object: L<Djet::Schema::Result::Djet::Node>

=cut

__PACKAGE__->belongs_to(
  "order",
  "Djet::Schema::Result::Djet::Node",
  { id => "order_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-09-03 07:47:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I1pUVADVabFIIMBqfnSAIA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
