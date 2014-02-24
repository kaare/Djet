package Jet::Role::Breadcrumbs;

use MooseX::MethodAttributes::Role;
use List::MoreUtils qw{ any uniq };

=head1 NAME

Jet::Role::Breadcrumbs - put breadcrumbs on the stash

=head1 METHODS

=head2 data

Places the data nodes in reverse order on the stash with key breadcrumbs.

If the node's datatype has a breadcrumbs attribute, it will be omitted.

=cut

before data => sub {
	my $self = shift;
	my $stash = $self->stash;
	$stash->{breadcrumbs} = [ reverse grep {!$_->basetype->attributes->{breadcrumbs}} $self->response->data_nodes->all ];
};

1;
