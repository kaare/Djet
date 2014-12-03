package Djet::I18N;

use 5.010;
use strict;
use warnings;
use base 'Locale::Maketext';
use Locale::Maketext::Lexicon;

=head1 NAME

Djet::I18N

=head1 DESCRIPTION

Internationalization for Djet

=cut

sub get_handle {
	my ($self, $djet_root, $language) = @_;
	Locale::Maketext::Lexicon->import({
		$language => [
			#		Gettext => "locale/$language.po",
			Gettext => "$djet_root/locale/$language.po"
		],
		_auto   => 1,
	});
	return $self->SUPER::get_handle($language);
}

1;

# COPYRIGHT

__END__
