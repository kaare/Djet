package Djet::Part::NodeData::product;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jasonic::Part::NodeData::product

=head1 METHODS

=head2 init_price

Called with these parameters, in order to initiate them

=cut

sub init_price { }

=head2 price

Must return the price of the product

=cut

sub price { }

=head2 unit

Must return the unit of the product

=cut

sub unit { }

no Moose::Role;

1;

# COPYRIGHT

__END__
