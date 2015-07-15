package Djet::Trait::Field::Price;

use Moose::Role;

use POSIX qw(locale_h);
use locale;

=head1 NAME

Djet::Trait::Field::Price - decorate the price field

=cut

=head1 METHODS

=head2 formatted_value

Return a nicely formatted value

=cut

sub formatted_value {
	my $self = shift;
	my %params = @_;
	my $language = $self->model->config->config->{language_price};
	my $old_locale = setlocale(LC_MONETARY);
	setlocale(LC_MONETARY, $language);

	my $locale = localeconv();
	my $currency = $params{no_currency} ? '' : $locale->{int_curr_symbol};
	my $decpt = $locale->{mon_decimal_point};
	my $decdigits = $locale->{int_frac_digits};
	my $value = $self->value;
	if ($value =~ m/(\d+)[,.]?(\d*)/) {
		my $int = $1;
		my $frac = substr(sprintf("%.$decdigits" . 'f', ".$2"), 2, $decdigits) || '-';
		$value = "$currency$int$decpt$frac";
	}
	setlocale(LC_MONETARY, $old_locale);
	return $value;
}

sub add {
	my ($self, $add) = @_;
	$self->_set_value($self->value + $add);
}

no Moose::Role;

1;
