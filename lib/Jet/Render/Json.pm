package Jet::Render::Json;

use 5.010;
use Moose;
use namespace::autoclean;

use JSON;
use FindBin qw($Bin);
use Locale::Maketext::Simple (
	Path		=> "$Bin/locale/",
	Decode      => 1,
	Encoding    => 'locale',
);

with 'Jet::Role::Log';

=head1 NAME

Jet::Render::Json - Render json for Jet

=head1 DESCRIPTION

This is the Json class for L<Jet>.

=head1 ATTRIBUTES

=head2 serializer

The response serializer.

=cut

has json => (
	isa => 'JSON',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return JSON->new->pretty;
	},
);

=head1 METHODS

=head2 render

Renders the output as JSON

=cut

sub render {
	my ($self, $template, $stash) = @_;
	warn 'Rendering ' . $template;
my @dynadata = map {{title => $_->row->{part}, isFolder => 1}}  @{$stash->{basenode}->children };
use Data::Dumper;
warn Dumper \@dynadata;
	return $self->json->encode(\@dynadata);
}

__PACKAGE__->meta->make_immutable;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2013 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
