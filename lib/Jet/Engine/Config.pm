package Jet::Engine::Config;

use 5.010;
use Moose;

extends 'Jet::Engine::Default';
with qw/Jet::Role::Log Jet::Role::Update::Node Jet::Role::Config::Topmenu/;

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

=head2 before init_data

Decide if it's a topmenu or perhaps a new node

=cut

before 'init_data' => sub {
	my $self = shift;
	my $stash = $self->stash;
	if ($self->datanodes->rest_path eq '_jet_config') {
		my $request = $self->body->request;
		my $parent_path = $request->parameters->{parent_path};
		# New node:
		if (defined $parent_path) {
			$self->omit_run->{data} = 1;
			return $self->choose_basetype($parent_path);

		}
	} else {
		$stash->{topmenu} = $self->topmenu;
		$self->template('/config/basenode.tx');
		$self->omit_run->{data} = 1;
	}
};

=head2 before data

Control what to send when it's Jet config

=cut

before 'data' => sub {
	my $self = shift;
	my $stash = $self->stash;

	my $request = $self->body->request;
	# New node. There's a first pass ('GET') to build up the display.
	if (my $parent_id = $request->parameters->{parent_id} and my $basetype_id = $request->parameters->{basetype_id}) {
		$stash->{parent_id} = $parent_id;
		$stash->{basetype_id} = $basetype_id;
		$self->set_object($self->schema->resultset('Jet::DataNode')->new({
			parent_id => $parent_id,
			basetype_id => $basetype_id,
			datacolumns => '{}',
		}));
	}

	$stash->{node} = $self->object;
	$stash->{request} = $self->request;
	$self->edit_view;
};

=head2 edit_view

Do some view stuff

=cut

after edit_view => sub {
	my $self = shift;
	my $stash = $self->stash;
	my $basecols = {
		columns => [
			{
				type => 'Str',
				title => 'Basetype',
				value => $stash->{node}->basetype->name,
			},
			{
				type => 'Str',
				name => 'name',
				title => 'Name',
				value => $stash->{node}->name,
				updatable => 1,
			},
			{
				type => 'Str',
				name => 'title',
				title => 'Title',
				value => $stash->{node}->title,
				updatable => 1,
			},
			{
				type => 'Str',
				name => 'part',
				title => 'Part',
				value => $stash->{node}->part,
				updatable => 1,
			},
		]
	};
	$stash->{basecols} = $basecols;
	$self->template('basetype/jet/config/basenode_edit.tx');
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
