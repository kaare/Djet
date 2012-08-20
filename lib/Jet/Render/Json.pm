package Jet::Json;

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

Jet::Json - Json Class for Jet

=head1 DESCRIPTION

This is the Json class for L<Jet>.

=head1 ATTRIBUTES

=head2 serializer

The response serializer.

=cut

has serializer => (
	isa => 'Data::Serializer',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return Data::Serializer->new(
			serializer => 'json',
		);
	},
);

=head1 METHODS

=head2 render

Renders the output as JSON

=cut

sub render {
	my ($self, $template) = @_;
	warn 'Rendering ' . $template;
	return $self->json->encode($self->stash);
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
