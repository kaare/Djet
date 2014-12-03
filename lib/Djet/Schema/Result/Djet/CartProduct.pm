use utf8;
package Djet::Schema::Result::Djet::CartProduct;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Djet::Schema::Result::Djet::CartProduct

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

=head1 TABLE: C<djet.cart_products>

=cut

__PACKAGE__->table("djet.cart_products");

=head1 ACCESSORS

=head2 cart

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 sku

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 price

  data_type: 'numeric'
  default_value: 0
  is_nullable: 0
  size: [10,2]

=head2 position

  data_type: 'integer'
  is_nullable: 0

=head2 quantity

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 priority

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cart",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "sku",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "price",
  {
    data_type => "numeric",
    default_value => 0,
    is_nullable => 0,
    size => [10, 2],
  },
  "position",
  { data_type => "integer", is_nullable => 0 },
  "quantity",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "priority",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</cart>

=item * L</sku>

=back

=cut

__PACKAGE__->set_primary_key("cart", "sku");

=head1 RELATIONS

=head2 cart

Type: belongs_to

Related object: L<Djet::Schema::Result::Djet::Cart>

=cut

__PACKAGE__->belongs_to(
  "cart",
  "Djet::Schema::Result::Djet::Cart",
  { code => "cart" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-12-03 20:20:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vwoWOF6LRy8UN1rbnpInTw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
