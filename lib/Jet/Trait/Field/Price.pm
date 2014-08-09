package Jet::Trait::Field::Price;

use Moose::Role;

=head1 NAME

Jet::Trait::Field::Price - decorate the price field

=cut

requires qw/value/;

=head1 METHODS

=head2 formatted_value

Return a nicely formatted value

=cut

sub formatted_value {
	my $self = shift;
	my $currency = 'DKK';
	my $decpt = ',';
	my $value = $self->value;
	if ($value =~ m/(\d+)[,.]?(\d*)/) {
		my $int = $1;
		my $frac = $2 || '-';
		$value = "$currency $1$decpt$frac";
	}
	return $value;
}

1;
