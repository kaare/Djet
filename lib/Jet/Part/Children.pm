package Jet::Part::Children;

use 5.010;
use Moose::Role;
use namespace::autoclean;

with 'Jet::Part';

=head1 NAME

Jet::Part::Children - Put the children of a node(default basenode) on the stash

=head1 ATTRIBUTES

=cut

=head1 METHODS

=head2 data

Puts children nodes on the stash (as $self->stash->{children};

=cut

sub data {
	my $self = shift;
	my $nodename = $self->stash->{nodename} // 'basenode';
	my $childrenname = $self->stash->{childrenname} // 'children';
	$self->stash->{$childrenname} = $self->stash->{$nodename}->children;
}

no Moose::Role;

1;

# COPYRIGHT

__END__
