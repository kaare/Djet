package Jet::Config;

use 5.010;
use Moose;
use namespace::autoclean;

use Config::JFDI;
use FindBin qw/$Bin/;

use Jet::Schema;

with 'Jet::Role::Log';

=head1 NAME

Jet::Config - Jet Configuration

=head1 DESCRIPTION

The Jet configuration is a collection of all the data that Jet and its application need
to know about how to operate themselves.

=head1 ATTRIBUTES

=head2 jet_root

Jet's root path. This is the path to where the Jet software is - NOT the application!

=cut

has jet_root => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $path = __FILE__;
		$path =~ s|lib/+Jet/Config.pm||;
		return $path;
	},
	lazy => 1,
);

=head2 app_root

Jet's root path. This is the path to where the application software is

=cut

has app_root => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		return $Bin;
	},
);

=head2 base

The base directory (relative to the application's home dir) for the configuration file(s)

=cut

has base => (
	isa => 'Str',
	is  => 'ro',
	default => 'etc/',
);

=head2 config

The configuration is loaded from etc by default

NB! We need to find a nice way to pass the name. Probably a command line parameter.

=cut

has config => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $config_path = $self->app_root . '/' . $self->base;
		my $config = Config::JFDI->new(name => "jet", path => $config_path);
		return $config->get;
	},
);

=head2 renderers

Jet Renderers

=cut

has renderers => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		my %renderers;
		do {
			my $classname = "Jet::Render::$_";
			eval "require $classname" or die $@;
			$renderers{lc $_} = $classname->new(
				jet_root => $self->jet_root,
				config => $self,
			);
		} for qw/Html Json/;
		return \%renderers;
	},
	lazy => 1,
);

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
