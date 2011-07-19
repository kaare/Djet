package Jet::Context;

use 5.010;
use MooseX::Singleton;

use CHI;
use Jet::Config;
use Jet::Engine;

has config => (
	isa => 'Jet::Config',
	is => 'ro',
	lazy => 1,
	default => sub {
		return Jet::Config->new;
	},
);
has schema => (
	isa => 'Jet::Engine',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		my %connect_info;
		$connect_info{$_} = shift @{ $self->config->{config}{connect_info} } for qw/dbname username password connect_options/;
		return Jet::Engine->new(%connect_info);
	},
);
has response => (
	isa => 'Jet::Context::Response',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return Jet::::Context::Response->new;
	},
);
has 'cache' => (
	isa => 'Object',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		return CHI->new( %{ $self->config->{cache} } );
	},
);
has 'stash' => (
	is => 'rw',
	default => sub { {} },
	lazy => 1,
);
has 'node' => (
	isa => 'Jet::Node',
	is => 'rw',
#	lazy => 1,
);

sub recipe {
	my ($self) = @_;
	my @plugins;
	my $ctrl = Jet::Control->instance;
	my $type = $ctrl->module;
	my $typeconf = $ctrl->config->{basetypes}{$type};
# use Data::Dumper;
# say STDERR Dumper $typeconf, $ctrl->config;
	for my $key (keys %$typeconf) {
# say STDERR $key;
		given ($key) {
			when ('template') {}
			default {
				my $pluginconf = $typeconf->{$key};
# say Dumper $pluginconf, ref $self->cache;
				my $plugin_name = $pluginconf->{plugin};
				my $private = $self->private($pluginconf);
				eval "require $plugin_name" or die "Couldn't find plugin $plugin_name";
				push @plugins, $plugin_name->new(
					request => $self->request,
					node => $self->node,
				);
			}
		}
	}
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Jet::Context - The Context we work in

=head1 SYNOPSIS

=head1 Attributes

=head2 config

The configuration, as loaded from the configuration files

=head2 schema

Database

=head2 cache

Any cache to be used

=head2 stash

Where data from the flow is stashed

=head2 module

Which module we're in now