package Jet::Response;

use 5.010;
use Moose;

use Text::Xslate;
use FindBin qw($Bin);
use Locale::Maketext::Simple (
	Path		=> "$Bin/locale/",
	Decode      => 1,
	Encoding    => 'locale',
);

with 'Jet::Role::Log';

=head1 NAME

Jet::Response - Response Class for Jet

=head1 DESCRIPTION

This is the Response class for L<Jet>.

=head1 ATTRIBUTES

=head2 status

The response status. Default 200

=head2 headers

The response headers. Default html

=head2 output

The output content.

=head2 tx

The template engine

=cut

has config => (
	isa => 'Jet::Config',
	is => 'ro',
);
has 'jet_root' => (
	isa => 'Str',
	is => 'ro',
);
has 'stash' => (
	isa => 'HashRef',
	is => 'ro',
);

has status   => (isa => 'Int', is => 'rw', default => 200);
has headers  => (isa => 'ArrayRef', is => 'rw', default => sub { [ 'Content-Type' => 'text/html; charset="utf-8"' ] });
has output   => (isa => 'ArrayRef', is => 'rw', default => sub { [ 'Jet version 0.0000001' ]} );
has template => (isa => 'Str', is => 'rw' );
has tx       => (isa => 'Text::Xslate', is => 'ro', lazy => 1, default => sub {
	my $self = shift;
	my $tx = Text::Xslate->new(
		path => [ map {$_ . '/templates'} ('.', $self->jet_root) ],
		function => {
			l => sub {
				return loc(@_);
			},
			# l_raw => html_builder {
				# my $format = shift;
				# my @args = map { html_escape($_) } @_;
				# return $i18n->maketext($format, @args);
			# },
		},
	);
});

=head1 METHODS

=head2 render

Chooses the output renderer based on the requested response types

=cut

sub render {
	my $self = shift;
	$self->render_html;# if $c->rest->type eq 'HTML'; # XXX We can only do html for now
}

=head2 render_html

Renders the output as HTML

=cut

sub render_html {
	my $self = shift;
	loc_lang($self->config->{jet}{language});
	my $output = $self->tx->render($self->template, $self->stash);
	$self->output([ $output ]);
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
