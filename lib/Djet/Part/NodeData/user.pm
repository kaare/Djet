package Djet::Part::NodeData::user;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jasonic::Part::NodeData::user

=head1 METHODS

=head2 display_fields

Filters out password

=cut

sub display_fields {
	my $self = shift;
	return [ grep {$_->name ne 'password'} @{ $self->fields } ];
}

no Moose::Role;

1;

# COPYRIGHT

__END__
