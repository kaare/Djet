package Jet::Config;

use 5.010;
use Moose;
use namespace::autoclean;

use Config::Any;

use Jet::Stuff;

with 'Jet::Role::Log';

=head1 NAME

Jet::Config - Jet Configuration

=head1 SYNOPSIS

=head1 ATTRIBUTES

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

=cut

has config => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $savedir = qx{pwd};
		chomp $savedir;
		chdir $self->base;
		my $config_total = Config::Any->load_files({
			files => [glob '*'],
			use_ext => 1,
			flatten_to_hash => 1,
		});
		chdir $savedir or die 'wtf?';
		return $config_total;
	},
);

=head2 jet

The jet part of the config

=cut

has jet => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		return $self->config->{'jet.conf'};
	},
);

=head2 options

The options part of the config

=cut

has options => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		return $self->config->{'options.conf'};
	},
);

=head2 schema

Defaults to the schema (Jet::Stuff) as found through the configuration

=cut

has schema => (
	isa => 'Jet::Stuff',
	is => 'ro',
	default => sub {
		my $self = shift;
		my @connect_info = @{ $self->jet->{connect_info} };
		my %connect_info;
		$connect_info{$_} = shift @connect_info for qw/dbname username password connect_options/;
		my $schema = Jet::Stuff->new(%connect_info);
	},
);

=head1 METHODS

=head2 private

Return the private config

For future use

=cut

sub private {
	my ($self, $module) = @_;
	return {};
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
