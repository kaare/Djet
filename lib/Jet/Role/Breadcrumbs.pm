package Jet::Role::Breadcrumbs;

use MooseX::MethodAttributes::Role;
use List::MoreUtils qw{ any uniq };

=head1 NAME

Jet::Role::Breadcrumbs - put breadcrumbs on the stash

=head1 METHODS

=head2 data

=cut

before data => sub {
	my $self = shift;
	my $stash = $self->stash;
	$stash->{breadcrumbs} = [ reverse $self->response->data_nodes->all ];
};

1;
