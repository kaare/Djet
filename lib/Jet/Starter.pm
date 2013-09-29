package Jet::Starter;

use Moose;

use Jet;
use Jet::Config;
use Jet::Request;

=head1 ATTRIBUTES

=head2 jet_root

Jet's root path

=cut

has jet_root => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $path = __FILE__;
		$path =~ s|lib/+Jet/Starter.pm||;
		return $path;
	},
	lazy => 1,
);

=head2 config

Jet configuration

=cut

has config => (
	is => 'ro',
	isa => 'Jet::Config',
	default => sub {
		my $self = shift;
		my $configbase = 'etc/';
		return Jet::Config->new(base => $configbase);
	},
	lazy => 1,
);
has schema => (
	is => 'ro',
	isa => 'Jet::Schema',
	default => sub {
		my $self = shift;
		my $config = $self->config;
		return $config->schema;
	},
	lazy => 1,
);
has basetypes => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		my $schema = $self->schema;
		return { map { $_->id =>  $_} $schema->resultset('Basetype')->search };
	},
	lazy => 1,
);
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
				config => $self->config,
			);
		} for qw/Html Json/;
		return \%renderers;
	},
	lazy => 1,
);

has app => (
	is => 'ro',
	isa => 'CodeRef',
	default => sub {
		my $self = shift;
		return sub {
			my $env = shift;
			my $request = Jet::Request->new(
				env => $env,
				config => $self->config,
				schema => $self->schema,
				basetypes => $self->basetypes,
				renderers => $self->renderers,
			);
			my $machine = Jet->new(request => $request);
			$machine->process(@_);
		};
	},
	lazy => 1,
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

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
