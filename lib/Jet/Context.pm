package Jet::Context;

use 5.010;
use MooseX::Singleton;

use CHI;
use Jet::Config;
use Jet::Engine;
use Jet::Response;

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

=head2 node

The base node

=head2 response

The response object

=cut

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
has cache => (
	isa => 'Object',
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		return CHI->new( %{ $self->config->{cache} } );
	},
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
	writer => '_response',
);
has stash => (
	isa       => 'HashRef',
	is        => 'ro',
	writer => '_stash',
	lazy => 1,
	default => 	sub { {} },
);
has node => (
	isa => 'Jet::Node',
	is => 'rw',
);

=head1 METHODS

=head2 clear

Clear request specific attributes

=cut

sub clear {
	my $self = shift;
	$self->_response(Jet::Response->new);
	$self->_stash({});
}

=head2 recipe

WIP - provide a recipe for a workflow for a base type

=cut

sub recipe {
	my ($self) = @_;
	my @plugins;
	my $ctrl = Jet::Control->instance;
	my $type = $ctrl->module;
	my $typeconf = $ctrl->config->{basetypes}{$type};
	for my $key (keys %$typeconf) {
		given ($key) {
			when ('template') {}
			default {
				my $pluginconf = $typeconf->{$key};
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

__END__
