package Jet::Engine::Config;

use 5.010;
use Moose;

extends 'Jet::Engine::Default';
with qw/
	Jet::Role::Log
	Jet::Role::Update::Node
/;

=head1 NAME

Jet::Engine - Configure Jet

=head1 DESCRIPTION

Jet::Engine::Config configures Jet data and nodes.

It includes the roles L<Jet::Role::Update::Node> and L<Jet::Role::Config::Topmenu>.

=head1 ATTRIBUTES

=head1 METHODS

=head2 _build_validator

If it's a new node, we require some more attributes

=cut

before _build_validator => sub {
	my $self = shift;
	my $dfv = $self->dfv;
	return unless $self->is_new;

	push @{ $dfv->{required} }, qw/part parent_id basetype_id/;
	$self->set_dfv($dfv);
};

=head2 before set_base_object

Tell the update role that we will make a new node.

=cut

before 'set_base_object' => sub {
	my $self = shift;
	return if $self->rest_path or $self->has_object;

	$self->set_object($self->schema->resultset('Jet::DataNode')->new({
		basetype_id => 1,
		parent_id => 1,
		datacolumns => '{}',
	}));
	$self->is_new(1);
};

=head2 before data

Control what to send when it's Jet config

=cut

before 'data' => sub {
	my $self = shift;
	my $object = $self->object;

	my $basecols = {
		columns => [
			{
				type => 'Str',
				title => 'Basetype',
				value => $object->basetype->name,
			},
			{
				type => 'Str',
				name => 'name',
				title => 'Name',
				value => $object->name,
				updatable => 1,
			},
			{
				type => 'Str',
				name => 'title',
				title => 'Title',
				value => $object->title,
				updatable => 1,
			},
			{
				type => 'Str',
				name => 'part',
				title => 'Part',
				value => $object->part,
				updatable => 1,
			},
		]
	};
	$self->stash->{basecols} = $basecols;
	$self->stash->{node} = $object;
};

=head2 post_is_create

Decide if we're creating a new node

=cut

sub post_is_create {
	my $self = shift;
	my $request = $self->body->request;
	return ($request->parameters->{parent_id} and $request->parameters->{basetype_id}) ?
		$self->is_new(1) :
		0;
}

=head2 create_path

Process the POST request for creating a node

=cut

sub create_path {
	my $self = shift;
	my $request = $self->body->request;
	my $parent_id = $request->parameters->{parent_id};
	my $basetype_id = $request->parameters->{basetype_id};
	$self->set_object($self->schema->resultset('Jet::DataNode')->new({
		parent_id => $parent_id,
		basetype_id => $basetype_id,
		datacolumns => '{}',
	}));
	return join '/', $self->basenode->node_path, $request->parameters->{part};
}

=head2 choose_basetype

Put parameters on the stash for the choose_basetype template

=cut

sub choose_basetype {
	my ($self, $parent_path) = @_;
	my @basetypes = $self->schema->resultset('Jet::Basetype')->search(undef, {order_by => 'id'});
	$self->stash->{basetypes} = [ @basetypes ];
	$self->template('/config/basenode_choose_basetype.tx');
}

=head2 edit_updated

Override the role method to do nothing

=cut

sub edit_updated {}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
