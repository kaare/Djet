package Djet::Config;

use 5.010;
use Moose;
use namespace::autoclean;

use Config::JFDI;
use FindBin qw/$Bin/;
use Log::Any;
use Log::Any::Adapter;

use Djet::Schema;
use Djet::I18N;

with 'Djet::Role::Log';

=head1 NAME

Djet::Config - Jet Configuration

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
			my $classname = "Djet::Render::$_";
			eval "require $classname" or die $@;
			$renderers{lc $_} = $classname->new(
				config => $self,
			);
		} for qw/Html Json/;
		return \%renderers;
	},
	lazy => 1,
);

=head2 log_category

Jet logger's category. Default 'jet'.

=cut

has log_category => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $config = $self->config->{log} // {};
		return $config->{category} // 'jet';
	},
	lazy => 1,
);

=head2 log_adapter

The name of Jet logger's adapter. Default 'Stdout'.

=cut

has log_adapter => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $config = $self->config->{log} // {};
		return $config->{category} // 'Stdout';
	},
	lazy => 1,
);

=head2 log

Jet logger

=cut

has log => (
	is => 'ro',
	#isa => 'Log::Any::Adapter',
	default => sub {
		my $self = shift;
		my $category = $self->log_category;
		my $logger = Log::Any->get_logger(category => $category);
		my $adapter = $self->log_adapter;
		Log::Any::Adapter->set($adapter);
		$logger->info("Log adapter $adapter for $category started");
		return $logger;
	},
	lazy => 1,
);

=head2 i18n

The localization handler

=cut

has i18n => (
	isa => 'Djet::I18N',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $language = $self->config->{language};
		my $jet_root = $self->jet_root;
		return Djet::I18N->get_handle($jet_root, $language);
	},
);

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
