use utf8;
package Jet::Schema::Result::Jet::DataNode;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Jet::Schema::Result::Jet::DataNode

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

  data_type: 'json'
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
  { data_type => "json", is_nullable => 1 },
  "fts",
  { data_type => "tsvector", is_nullable => 1 },
  "data_created",
  { data_type => "timestamp", is_nullable => 1 },
  "data_modified",
  { data_type => "timestamp", is_nullable => 1 },
  "node_id",
  { data_type => "integer", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07038 @ 2014-02-21 09:04:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RlQmiuz5mxXkmDoaH5QVMg

use JSON;
use Encode;
use vars qw($AUTOLOAD);

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
	inflate=>sub {
		my ($datacol, $self) = @_;
		my $data = $self->basetype->fields->new( datacolumns => JSON->new->allow_nonref->decode($datacol) );
#		$self->field_inflate($data);
		return $data;
	},
	deflate=>sub {
		my ($datacol, $self) = @_;
		#	$self->field_deflate($datacol);
		$self->update_fts($datacol);
		return Encode::decode('utf-8', JSON->new->allow_nonref->encode(shift));
	},
});

=head2 field_inflate

Specific inflating for each field

=cut

sub field_inflate {
	my ($self, $data) = @_;
	my $fields = $self->datacolumns;
	while (my ($name, $value) = each %$data) {
		die "No field $name for datanode " . $self->id unless my $field = $fields->can($name);

		$data->{$name} = $fields->$field->unpack($value);
	}
}

=head2 field_deflate

Specific deflating for each field

=cut

sub field_deflate {
	my ($self, $datacol) = @_;
	my $fields = $self->datacolumns;
	while (my ($name, $value) = each %$datacol) {
		die "No field $name for datanode " . $self->id unless my $field = $fields->can($name);

		$datacol->{$name} = $fields->$field->pack($value);
	}
}

=head2 update_fts

Update the fts columns with the relevant data from datacolumns

=cut

sub update_fts {
	my ($self, $datacol) = @_;
	# jet.basetype
	my $basetype = $self->basetype;

	my $fts = $self->title;
	for my $field (@{ $self->datacolumns->fields }) {
		next unless $field->searchable;

		$fts .= ' ' . $field->for_search;
	}

	$fts =~ s/[,-\/:)(]/ /g;
	$self->fts(lc $fts);
}

=head2 autoload

Method calls are checked to see if they match a JSON column. If so, they're handled as ordinary accessors

=cut

sub AUTOLOAD {
	my $self = shift;
	$AUTOLOAD =~ /::(\w+)$/;
	my $method = $1;
	return if $method eq 'fields';

	my $fields = $self->datacolumns;
	die "No field $method for datanode " . $self->id unless my $field = $fields->can($method);

	return $fields->$field(@_);
}

with qw/
	Jet::Role::DB::Result::Node
/;

# NB The following attributes and parameters are 'stolen' from Jet::Schema::Result::Jet::Data, as dbicdump didn't find them

=head2 basetype

Type: belongs_to

Related object: L<Jet::Schema::Result::Jet::Basetype>

=cut

__PACKAGE__->belongs_to(
  "basetype",
  "Jet::Schema::Result::Jet::Basetype",
  { id => "basetype_id" },
  { is_deferrable => 0, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

# NB The following attributes and parameters are 'stolen' from Jet::Schema::Result::Jet::Node, as dbicdump didn't find them

=head1 PRIMARY KEY

=over 4

=item * L</node_id>

=back

=cut

__PACKAGE__->set_primary_key("node_id");

=head1 RELATIONS

=head2 children

Type: has_many

Related object: L<Jet::Schema::Result::Jet::DataNode>

=cut

__PACKAGE__->has_many(
  "children",
  "Jet::Schema::Result::Jet::DataNode",
  { "foreign.parent_id" => "self.node_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<Jet::Schema::Result::Jet::Node>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "Jet::Schema::Result::Jet::Node",
  { node_id => "parent_id" },
  {
	is_deferrable => 0,
	join_type	 => "LEFT",
	on_delete	 => "CASCADE",
	on_update	 => "CASCADE",
  },
);

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
