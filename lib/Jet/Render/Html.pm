package Jet::Render::Html;

use 5.010;
use Moose;
use namespace::autoclean;

use Text::Xslate;
use Locale::Maketext::Simple;

with 'Jet::Role::Log';

=head1 NAME

Jet::Render::Html - Render html for Jet

=head1 DESCRIPTION

This is the Render::Html class for L<Jet>.

=head1 ATTRIBUTES

=head2 tx

The template engine

=cut

has config => (
	isa => 'Jet::Config',
	is => 'ro',
);
has tx => (
	isa => 'Text::Xslate',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $template_path = $self->config->config->{template_path};
		my $tx = Text::Xslate->new(
			path => [ map {$_ . '/' . $template_path} ('.', $self->config->jet_root) ],
			function => {
				l => sub {
					return loc(@_);
				},
			},
		);
	},
);

=head1 METHODS

=head2 BUILD

Locale::Maketext::Simple only works with class variables. So we call import on that module.

=cut

sub BUILD {
	my $self = shift;
	my $app_root = $self->config->app_root;
	Locale::Maketext::Simple->import(
		Path		=> "$app_root/locale/",
		Decode		=> 1,
		Encoding	=> 'locale',
	)
}

=head2 render

Renders the output as HTML

=cut

sub render {
	my ($self, $template, $stash) = @_;
	loc_lang($self->config->config->{language});
	return $self->tx->render($template, $stash);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
