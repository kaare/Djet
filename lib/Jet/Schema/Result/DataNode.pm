use utf8;
package Jet::Schema::Result::DataNode;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Jet::Schema::Result::DataNode

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<jet.data_node>

=cut

__PACKAGE__->table("jet.data_node");

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

  data_type: 'prefix_range'
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
  { data_type => "prefix_range", is_nullable => 1 },
  "node_created",
  { data_type => "timestamp", is_nullable => 1 },
  "node_modified",
  { data_type => "timestamp", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-03 11:41:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xyQ2gX88tpQ1PhS51Rc3wg

with 'Jet::Role::DB::Result::Node';

=head1 ATTRIBUTES

=head2 basetype

The node's basetype

=cut

has basetype => (
	isa => 'Jet::Schema::Result::Basetype',
	is => 'ro',
	default	=> sub {
		my $self = shift;
		my $schema = $self->result_source->schema;

		return $schema->basetypes->{$self->basetype_id};
	},
	lazy => 1,
);

#NB The following attributes and parameters are 'stolen' from Jet::Schema::Result::Node, as dbicdump didn't find them

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

# __PACKAGE__->set_primary_key("node_id");

=head1 RELATIONS

=head2 nodes

Type: has_many

Related object: L<Jet::Schema::Result::Node>

=cut

__PACKAGE__->has_many(
  "nodes",
  "Jet::Schema::Result::DataNode",
  { "foreign.parent_id" => "self.node_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<Jet::Schema::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Jet::Schema::Result::Node",
  { node_id => "parent_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->meta->make_immutable;
1;

# COPYRIGHT

__END__
