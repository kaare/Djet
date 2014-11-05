package Jet::I18N;

use 5.010;
use strict;
use warnings;
use base 'Locale::Maketext';
use Locale::Maketext::Lexicon;

=head1 NAME

Jet::I18N

=head1 DESCRIPTION

Internationalization for Jet

=cut

sub get_handle {
	my ($self, $jet_root, $language) = @_;
	Locale::Maketext::Lexicon->import({
		$language => [
			#		Gettext => "locale/$language.po",
			Gettext => "$jet_root/locale/$language.po"
		],
		_auto   => 1,
	});
	return $self->SUPER::get_handle($language);
}

1;

# COPYRIGHT

__END__
