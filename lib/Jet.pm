package Jet;

use 5.010;
use Moose;
use Try::Tiny;
use CHI;

use Jet::Config;
use Jet::Stuff;
use Jet::Request;
use Jet::Response;
use Jet::Node;
use Jet::Exception;
use Jet::Engine;

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
	$basetypes = $schema->get_basetypes_href;
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
	my $stash  = {};
	my $response = Jet::Response->new(
		jet_root => $jet_root,
		config => $config,
		stash  => $stash,
	);
	my ($request, $node);
	try {
		$request = Jet::Request->new($env);
		$node = $self->find_node_path($request->path_info) || Jet::Exception->throw(NotFound => { message => $request->uri->as_string });
	} catch {
		my $e = shift;
		$stash->{exception} = $e;
		$response->template('generic/error' . $config->jet->{template_suffix});
		$node = Jet::Node->new(
			schema => $schema,
			basetypes => $basetypes,
			row =>{},
			endpath => '',
		);
	};
	my $engine = Jet::Engine->new(
		config => $config,
		schema => $schema,
		cache  => $cache,
		basetypes => $basetypes,
		request => $request,
		node   => $node,
		stash  => $stash,
		response => $response,
	);
	$engine->init;
	$engine->run;
	$engine->render;
	$response->render;
	return [ $response->status, $response->headers, $response->output ];
}

=head2 find_node_path

Accepts an url and returns a Jet::Node if the url points to a valid path in the system.

If not found, it goes one step up from find_node and tries to find something consistent with the path

=cut

sub find_node_path($) {
	my ($self, $path) = @_;
	$path =~ s|^(.*?)/?$|$1|; # Remove last character if slash
	my %nodeparams = (
		schema => $schema,
		basetypes => $basetypes,
	);
	my $nodedata = $schema->find_node({ node_path =>  $path });
	if ($nodedata) {
		my $baserole = $basetypes->{$nodedata->{basetype_id}}->{role};
		return $baserole ?
			Jet::Node->with_traits($baserole)->new(%nodeparams, row => $nodedata) :
			Jet::Node->new(%nodeparams, row => $nodedata);
	}

	# Find node at one level up. See if there is a path expression on that node
	$path =~ m|(.*)/(\w+)/?$|;
	my $node_path = $1;
	my $endpath = $2;
	$nodedata = $schema->find_node({ node_path =>  $node_path });
	return unless $nodedata;

	my $baserole = $basetypes->{$nodedata->{basetype_id}}->{role};
	# We'll save the endpath for later, where we'll see if there is a recipe
	return Jet::Node->with_traits($baserole)->new(
		%nodeparams,
		row => $nodedata,
		endpath => $endpath // '',
	);
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
