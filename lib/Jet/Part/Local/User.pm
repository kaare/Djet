package Jet::Part::Local::User;

use 5.010;
use Moose::Role;

=head1 NAME

Jet::Part::Local::User

=head1 DESCRIPTION

Add user information to the local object

=head1 ATTRIBUTES

=head2 user

The current user

=cut

has 'user' => (
	is => 'ro',
	isa => 'Maybe[Jet::Schema::Result::Jet::DataNode]',
	lazy_build => 1,
);

sub _build_user {
	my $self = shift;
	my $user = $self->session->{jet_user} // return;

	my $schema = $self->schema;
	my $user_basetype = $schema->basetype_by_name('user') or return '';

	my $user_row = $schema->resultset('Jet::DataNode')->find({
		basetype_id => $user_basetype->id,
		part => $user,
	}) or return;

	return $user_row;
}

no Moose::Role;

1;

# COPYRIGHT

__END__

