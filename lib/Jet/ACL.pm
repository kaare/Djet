package Jet::ACL;

use 5.010;
use Moose;
use namespace::autoclean;
use JSON;

with 'Role::Pg::Roles';

=head1 NAME

Jet::ACL

=head1 DESCRIPTION

Jet::ACL controls the roles, ie users and groups in Jet

=head1 METHODS

=head2 check_user

Checks if a user is logged in and allowed to access the basenode

=cut

sub check_login {
	my ($self, $session, $datanodes) = @_;
	my $user = $session->{jet_user} // 'guest';
	$self->set($user); # Act like this user from now on
	my $basenode = $datanodes->[0];
	my $acl = JSON->new->decode($basenode->acl);
	return $user unless my @group = keys %$acl;
	for my $group (@group) {
		return $user if $self->member_of(user => $user, group => $group);
	}
	return;
}

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

