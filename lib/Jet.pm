package Jet;

use 5.010;
use Moose;
use Try::Tiny;
use CHI;

use Jet::Basenode;
use Jet::Config;
use Jet::Engine;
use Jet::Exception;
use Jet::Failure;
use Jet::Request;
use Jet::Response;
use Jet::Stuff;

=head1 NAME

Jet

=head1 DESCRIPTION

Faster than an AWE2

=head1 SYNOPSIS

Experimental module

=head1 Class Attributes

configbase

=cut

our $jet_root;
our $configbase;
our $config;
our $schema;
our $cache;
our $basetypes;

=head1 METHODS

=head2 BEGIN

Build the Jet with roles

=cut

# ABSTRACT: A Modern Content Management System

BEGIN {
	# Init "Class Attributes"
	my $path = $INC{'Jet.pm'};
	$path =~ s|lib/+Jet.pm||;
	$jet_root = $path;
	$configbase = 'etc/';
	$config = Jet::Config->new(base => $configbase);
	my @connect_info = @{ $config->jet->{connect_info} };
	my %connect_info;
	$connect_info{$_} = shift @connect_info for qw/dbname username password connect_options/;
	$schema = Jet::Stuff->new(%connect_info);
	$basetypes = $schema->get_expanded_basetypes;
	$cache = CHI->new( %{ $config->jet->{cache} } );

	# Roles
	with 'Jet::Role::Log';
	my $role_config = $config->options->{Jet}{role};

	my @roles = ref $role_config ? @{ $role_config }: ($role_config);
	with ( map "Jet::Role::$_", @roles ) if @roles;
}

=head2 run_psgi

Entry point from psgi

=cut

sub run_psgi($) {
	my ($self, $env) = @_;
	my $request = Jet::Request->new($env);
	my $stash  = {request => $request};
	my $response = Jet::Response->new(
		jet_root => $jet_root,
		config => $config,
		stash  => $stash,
	);
	my $basenode;
	try {
		$basenode = $self->find_node_path($request->path_info, $stash);
		# Set a default html template if there are no arguments. We should probably look for response type to determine if it's a REST request first though
		my $jet_config = $config->jet;
		$response->template($jet_config->{template_path} . $basenode->get_column('node_path') . $jet_config->{template_suffix}) unless @{ $basenode->arguments};
	} catch {
		my $e = shift;
		Jet::Failure->new(
			exception => $e,
			config => $config,
			schema => $schema,
			cache  => $cache,
			basetypes => $basetypes,
			request => $request,
			basenode => $basenode,
			stash  => $stash,
			response => $response,
		);
	};
	unless ($response->has_output) {
		$stash->{basenode} = $basenode;
		my $engine = Jet::Engine->new(
			arguments => $basenode->basetype->engine_arguments,
			config => $config,
			schema => $schema,
			cache  => $cache,
			basetypes => $basetypes,
			request => $request,
			basenode => $basenode,
			stash  => $stash,
			response => $response,
		);
		try {
			$engine->conditions;
			$engine->parts;
			$response->render;
		} catch {
			my $e = shift;
			Jet::Failure->new(
				exception => $e,
				config => $config,
				schema => $schema,
				cache  => $cache,
				basetypes => $basetypes,
				request => $request,
				basenode => $basenode,
				stash  => $stash,
				response => $response,
			);
		};
	}
	return [ $response->status, $response->headers, $response->output ];
}

=head2 find_node_path

Accepts an url and returns a Jet::Basenode if the url points to a valid path in the system.

=cut

sub find_node_path($) {
	my ($self, $path, $stash) = @_;
	$path =~ s|^(.*?)/?$|$1|; # Remove last character if slash
	my %nodeparams = (
		schema => $schema,
		basetypes => $basetypes,
	);
	my $nodedata = $schema->find_basenode($path);
	Jet::Exception->throw(NotFound => { message => $path }) unless $nodedata;

	my $basedata = shift @$nodedata;
	# Find the path arguments
	my $basepath = $basedata->{node_path};
	$path =~ /$basepath(.*)/;
	my @arguments = split '/', $1;
	shift @arguments;
	# Save the remaining nodes on the stash
	$stash->{nodes}{$_->{node_id}} = Jet::Node->new(row => $_) for @$nodedata;

	my $baserole = $basetypes->{$basedata->{basetype_id}}->node_role;
	return $baserole ?
		Jet::Basenode->with_traits($baserole)->new(%nodeparams, row => $basedata, arguments => \@arguments) :
		Jet::Basenode->new(%nodeparams, row => $basedata);
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
