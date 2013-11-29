package Jet::Fields;

use 5.010;
use Moose;
use namespace::autoclean;

use JSON;

use Jet::Field;

with 'Jet::Role::Log';

=head1 NAME

Jet::Fields - Jet Fields Base Class

=head1 SYNOPSIS


=head1 ATTRIBUTES

=head3 datacolumns

The data columns

=cut

has datacolumns => (
	isa => 'ArrayRef',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__
