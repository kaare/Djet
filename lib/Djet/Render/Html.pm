package Djet::Render::Html;

use 5.014;
use Moose;
use namespace::autoclean;

use Text::Xslate;
use URI::Escape;
use HTML::Escape 'escape_html';

with 'Djet::Part::Log';

=head1 NAME

Djet::Render::Html - Render html for Djet

=head1 DESCRIPTION

This is the Render::Html class for L<Djet>.

=head1 ATTRIBUTES

=head2 config

The Djet configuration.

=cut

has config => (
	isa => 'Djet::Config',
	is => 'ro',
);

=head2 tx

The template engine

=cut

has tx => (
	isa => 'Text::Xslate',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $template_path = $self->config->config->{template_path};
		my $search_path = [ map {$_ . '/' . $template_path} ($self->config->app_root, $self->config->djet_root) ];
		my $tx = Text::Xslate->new(
			path => $search_path,
			function => {
				l => sub {
					return $self->config->i18n->maketext(@_);
				},
				scale_image => sub {
					return scale_image(@_);
				},
				url_encode => sub {
					return url_encode(@_);
				},
				linkify => sub {
					return linkify(@_);
				},
			},
		);
	},
);

=head2 scale_image

Xslate function to scale image. Requires L<Plack::Middleware::Image::Scale>.

Write something like

  <: scale_image($product_image, '720x540') :>

in the template.

=cut

sub scale_image {
	my ($filename, $scale) = @_;
	return '' unless $filename;

	my @file = split /\./, $filename;
	return $filename unless @file > 1;

	my $ext = pop @file;
	my $name = join '.', @file;
	return $name . '_' . $scale . '.' . $ext;
}

=head2 linkify

Xslate function to change markdown style links to local links

Write something like

  <: html text with marked links | linkify :>

    [Produkt vi har](product:<link>),
    [Produkt vi har](product),
    [Søgning](search:<link>),
    [Søgning](search),
    [List produkter](list:<link>),
    [List produkter](list),

in the template.

=cut

sub linkify {
	my ($html) = @_;
	return '' unless $html;

	$html =~ s/
        \[ (.+?) \]                 # Catch [Some text] as $1
        \(
            (product|search|list)   # Define what kind of markup we have in $2
            (?: : (.+?) )?          # Optionally have a link (as $3)
        \)
    /make_href($1, $2, $3)/xige;

	return $html;
}

=head2 make_href

Return an url from a linked text

=cut

sub make_href {
    my ($text, $type, $link) = @_;
    $link //= $text;
    my $href;
    for ($type) {
        $href = $link // $text when /^product$/;
        $href = "/search?search_phrase=$link" when /^search$/;
        $href = "/list/$link" when /^list$/;
        default { $href = '' }
    }

    my $a = qq{<a href="$href">$text</a>};
    return $a;
}

=head2 url_encode

Xslate function to url encode a hashref.

Write something like

  <: $query_parameters | url_encode :>

in the template.

=cut

sub url_encode {
	my ($params) = @_;
	return 'FAIL' unless ref $params eq 'HASH' or ref $params eq 'Hash::MultiValue';

	return join '&', map{join '=', map uri_escape($_), $_, defined($params->{$_}) ? $params->{$_} : undef} keys %$params;
}

=head1 METHODS

=head2 render

Renders the output as HTML

=cut

sub render {
	my ($self, $stash, $template) = @_;
	return $self->tx->render($template, $stash);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
