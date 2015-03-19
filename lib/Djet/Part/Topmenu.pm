package Djet::Part::Topmenu;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Topmenu

=head1 DESCRIPTION

Puts a topmenu on the stash

=head1 ATTRIBUTES

=head2 menu_basenode

The base for the menu. Menu items are children nodes.

=cut

has 'menu_basenode' => (
	is => 'ro',
	isa => 'DBIx::Class',
	lazy_build => 1,
);

sub _build_menu_basenode {
	my $self= shift;
	my $model = $self->model;
	my $domain_basetype = $model->basetype_by_name('domain');
	return $model->datanode_by_basetype($domain_basetype);
}

=head2 topmenu

Return the topmenu (an arrayref)

=cut

has 'topmenu' => (
	is => 'ro',
	isa => 'ArrayRef',
	lazy_build => 1,
);

sub _build_topmenu {
	my $self= shift;
	my $model = $self->model;
	my $menu_node = $self->menu_basenode;
	my $current_path = $model->basenode->node_path;
	my $search = {
		"datacolumns->>'topmenu'" => 'on',
	};
	my $options = {
		order_by => [qw/node_id/],
	};
	return [ map {$_->current(1) if index($current_path, $_->node_path) > -1; $_} $menu_node->children->search($search, $options)->all ];
}

no Moose::Role;

1;

# COPYRIGHT

__END__
