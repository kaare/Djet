package Djet::ACL;

use 5.010;
use Moose;
use namespace::autoclean;
use JSON;

with 'Role::Pg::Roles';

=head1 NAME

Djet::ACL

=head1 DESCRIPTION

Djet::ACL controls the roles, ie users and groups in Djet

=head1 METHODS

=head2 check_login

Checks if a user is logged in and allowed to access the basenode

=cut

sub check_login {
	my ($self, $session, $datanodes) = @_;
	my $user = $session->{djet_user} // 'guest';
	my $basenode = $datanodes->[0];
	my $acl = JSON->new->decode($basenode->acl);
	return $user unless my @group = keys %$acl;

	# Check if user has the correct group and act as that user if so
	for my $group (@group) {
		return $self->set_role(role => $user) && $user if $self->member_of(user => $user, group => $group);
	}
	return;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

