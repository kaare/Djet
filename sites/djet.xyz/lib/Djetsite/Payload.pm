package Djetsite::Payload;

use 5.010;
use Moose;

extends 'Djet::Payload';

with qw/
	Djet::Part::Topmenu
	Djet::Part::Payload::Basic
/;

=head1 NAME

Jasonic::Payload.

=head1 DESCRIPTION

The payload of Djetsite.

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
