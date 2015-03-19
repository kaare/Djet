package Djet::Part::Basenode;

use 5.010;
use Moose::Role;
use namespace::autoclean;

with 'Djet::Part';

=head1 NAME

Djet::Part - Put the basenode on the stash

=head1 ATTRIBUTES

=cut

=head1 METHODS

=head2 data

Puts the basenode on the stash (as $model->stash->{basenode};

=cut

sub data {
	my $self = shift;
	my $model = $self->model;
	$model->stash->{basenode} = $model->basenode;
}

no Moose::Role;

1;

# COPYRIGHT

__END__
