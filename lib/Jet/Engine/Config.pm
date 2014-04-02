package Jet::Engine::Config;

use 5.010;
use Moose;

extends 'Jet::Engine::Default';
with qw/Jet::Role::Update::Node Jet::Role::Config::Topmenu/;

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

=head2 data

Control what to send when it's Jet config

=cut

after data => sub {
	my $self = shift;
	my $stash = $self->stash;
	if ($self->datanodes->rest_path eq '_jet_config') {
		my $request = $self->body->request;
		my $parent_path = $request->parameters->{parent_path};
		return $self->choose_basetype($parent_path) if defined $parent_path;

		# New node. There's a first pass ('GET') and a second ('POST').
		if (my $parent_id = $request->parameters->{parent_id} and my $basetype_id = $request->parameters->{basetype_id}) {
			if ($request->method eq 'POST') {
				$self->is_new(1);
			} else {
				$stash->{parent_id} = $parent_id;
				$stash->{basetype_id} = $basetype_id;
			}
			$self->set_object($self->schema->resultset('Jet::DataNode')->new({
				parent_id => $parent_id,
				basetype_id => $basetype_id,
				datacolumns => '{}',
			}));
		}

		$self->edit;
		$stash->{node} = $self->object;
		$stash->{request} = $self->request;

		# Return
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
	} else {
		$stash->{topmenu} = $self->topmenu;
		$self->template('/config/basenode.tx');
	}
};

=head2 choose_basetype

Put parameters on the stash for the choose_basetype template

=cut

sub choose_basetype {
	my ($self, $parent_path) = @_;
	my @basetypes = $self->schema->resultset('Jet::Basetype')->search(undef, {order_by => 'id'});
	$self->stash->{basetypes} = [ @basetypes ];
	$self->response->template('/config/basenode_choose_basetype.tx');
}

=head2 edit_updated

Override the role method to do nothing

=cut

sub edit_updated {}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
