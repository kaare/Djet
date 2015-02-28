use utf8;
package Djet::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-02-07 04:17:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BsDqak3shl0NT6WdtdKzMA

=head1 NAME

Djet::Schema

=head1 DESCRIPTION

The DBIC schema as generated from  DBIx::Class::Schema::Loader

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
