use utf8;
package Djet::Schema::Result::Djet::DataNode;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Djet::Schema::Result::Djet::DataNode

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
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<djet.data_node>

=cut

__PACKAGE__->table("djet.data_node");

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

  data_type: 'json'
  is_nullable: 1

=head2 acl

  data_type: 'json'
  is_nullable: 1

=head2 fts

  data_type: 'tsvector'
  is_nullable: 1

=head2 data_created

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 data_modified

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 data_created_by

  data_type: 'text'
  is_nullable: 1

=head2 data_modified_by

  data_type: 'text'
  is_nullable: 1

=head2 node_id

  data_type: 'integer'
  is_nullable: 0

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

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 node_modified

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 node_created_by

  data_type: 'text'
  is_nullable: 1

=head2 node_modified_by

  data_type: 'text'
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
  { data_type => "json", is_nullable => 1 },
  "acl",
  { data_type => "json", is_nullable => 1 },
  "fts",
  { data_type => "tsvector", is_nullable => 1 },
  "data_created",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "data_modified",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "data_created_by",
  { data_type => "text", is_nullable => 1 },
  "data_modified_by",
  { data_type => "text", is_nullable => 1 },
  "node_id",
  { data_type => "integer", is_nullable => 0 },
  "parent_id",
  { data_type => "integer", is_nullable => 1 },
  "part",
  { data_type => "text", is_nullable => 1 },
  "node_path",
  { data_type => "prefix_range", is_nullable => 1 },
  "node_created",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "node_modified",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "node_created_by",
  { data_type => "text", is_nullable => 1 },
  "node_modified_by",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-02-07 04:21:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2jatFbQnKsY9TTMUHVFlzQ

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
	deflate=>sub { JSON->new->allow_nonref->encode(shift); },
});

with qw/
	Djet::Part::DB::Result::Data
	Djet::Part::DB::Result::Node
/;

# NB The following attributes and parameters are 'stolen' from Djet::Schema::Result::Djet::Data, as dbicdump didn't find them

=head2 basetype

Type: belongs_to

Related object: L<Djet::Schema::Result::Djet::Basetype>

=cut

__PACKAGE__->belongs_to(
  "basetype",
  "Djet::Schema::Result::Djet::Basetype",
  { id => "basetype_id" },
  { is_deferrable => 0, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

# NB The following attributes and parameters are 'stolen' from Djet::Schema::Result::Djet::Node, as dbicdump didn't find them

=head1 PRIMARY KEY

=over 4

=item * L</node_id>

=back

=cut

__PACKAGE__->set_primary_key("node_id");

=head1 RELATIONS

=head2 children

Type: has_many

Related object: L<Djet::Schema::Result::Djet::DataNode>

=cut

__PACKAGE__->has_many(
  "children",
  "Djet::Schema::Result::Djet::DataNode",
  { "foreign.parent_id" => "self.node_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<Djet::Schema::Result::Djet::Node>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Djet::Schema::Result::Djet::DataNode",
  { node_id => "parent_id" },
  {
	is_deferrable => 0,
	join_type	 => "LEFT",
	on_delete	 => "CASCADE",
	on_update	 => "CASCADE",
  },
);

=head2 current

Switch to set if this node is current.

=cut

has 'current' => (
	is => 'rw',
	isa => 'Bool',
	default => 0,
	lazy => 1,
);

# Owner methods are here. They could also be on the node and data classes respectively, but there's a name problem with that (modified_by vs node_modified_by etc).

=head2 node_owner

Return a result row with the owner.

=cut

sub node_owner {
	my $self = shift;
	my $user_type = $self->result_source->schema->resultset('Djet::Basetype')->find({name => 'user'}) or return;

	return $user_type->find_related('datanodes', {part => $self->node_modified_by});
}

=head2 node_owner_name

Either the name from the owner row, or the modified_by

=cut

sub node_owner_name {
	my $self = shift;
	my $node_owner = $self->node_owner or return $self->node_modified_by;

	return $node_owner->user_name;
}

=head2 data_owner

Return a result row with the owner.

=cut

sub data_owner {
	my $self = shift;
	my $user_type = $self->result_source->schema->resultset('Djet::Basetype')->find({name => 'user'}) or return;

	return $user_type->find_related('datanodes', {part => $self->data_modified_by});
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
