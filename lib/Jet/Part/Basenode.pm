package Jet::Part::Basenode;

use 5.010;
use Moose::Role;
use namespace::autoclean;

with 'Jet::Part';

=head1 NAME

Jet::Part - Put the basenode on the stash

=head1 ATTRIBUTES

=cut

=head1 METHODS

=head2 data

Puts the basenode on the stash (as $self->stash->{basenode};

=cut

sub data {
	my $self = shift;
	$self->stash->{basenode} = $self->basenode;
}

no Moose::Role;

1;

# COPYRIGHT

__END__
