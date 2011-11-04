package Jet;

use 5.010;
use Moose;
use Plack::Request;
use Jet::Node;
use Jet::Context;
use Try::Tiny;
use Jet::Exception;

=head1 NAME

Jet

=head1 DESCRIPTION

Faster than an AWE2

=head1 SYNOPSIS

Experimental module

=head1 METHODS

=head2 BEGIN

Build the Jet with roles

=cut

# ABSTRACT: A Modern Content Management System

BEGIN {
	my $self = shift;
	with 'Jet::Role::Log';
	my $c = Jet::Context->instance;
	my $config = $c->config->options->{Jet};
	my @roles = ref $config->{role} ? @{ $config->{role} }: ($config->{role});
	with ( map "Jet::Role::$_", @roles ) if @roles;
}

=head2 run_psgi

Entry point from psgi

=cut

sub run_psgi($) {
	my ($self, $env) = @_;
	my $c = Jet::Context->instance;
	# Clear request specific attributes
	$c->clear;
	try {
		$self->handle_request($env);
	} catch {
		my $e = shift;
		$c->stash->{exception} = $e;
		$c->response->template('templates/generic/error' . $c->config->jet->{template_suffix});
	};
	$c->response->render;
	return [ $c->response->status, $c->response->headers, $c->response->output ];
}

=head2 handle_request

Handle the request

=cut

sub handle_request($) {
	my ($self, $env) = @_;
	my $c = Jet::Context->instance;
	my $req = Plack::Request->new($env);
	$c->_request($req);
	my $node = $self->find_node($req->path_info) || Jet::Exception->http_throw(NotFound => { message => $req->uri->as_string });
	$c->node($node);
	return $self->go($req, $node);
}

=head2 find_node

Accepts an url and returns a Jet::Node if the url points to a valid path in the system.

If not found, it goes one step up from find_node and tries to find something consistent with the path

=cut

sub find_node($) {
	my ($self, $path) = @_;
	my $c = Jet::Context->instance;
	my $schema = $c->schema;
	my $nodedata = $schema->find_node({ node_path =>  $path });
	return Jet::Node->new(
		row => $nodedata,
	) if $nodedata;

	# Find node at one level up. See if there is a path expression on that node
	$path =~ m|(.*)/(\w+)$|;
	my $node_path = $1;
	my $endpath = $2;
	$nodedata = $c->schema->find_node({ node_path =>  $node_path });
	return unless $nodedata and $self->node_path_match($nodedata, $endpath);

	# We'll save the endpath for later, where we'll see if there is a recipe
	return Jet::Node->new(
		row => $nodedata,
		endpath => $endpath
	);
}

=head2 node_path_match

Check a node and see if there is a match for the given "extra" path

=cut

sub node_path_match {
	my ($self, $nodedata, $endpath) = @_;
	return 1; # XXX Testing
}

=head2 go

Does the actual data processing and rendering for this node

=cut

sub go {
	my ($self, $req) = @_;
	my $c = Jet::Context->instance;
	my $node = $c->node;
	my $recipe = $c->recipe;
	# Check if the endpath was correct
	Jet::Exception->throw(NotFound => { message => $req->uri->as_string })
		if $c->node->endpath and !$recipe->{paths}{$c->node->endpath};

	my $steps = $c->node->endpath ? 
		$recipe->{paths}{$c->node->endpath} :
		$recipe->{steps};
	for my $step (@$steps) {
		my $engine_name = "Jet::Engine::$step->{plugin}";
		print STDERR "\n$engine_name: ";
		eval "require $engine_name" or next;
		print STDERR "found ";
		next if $step->{verb} and !($c->rest->verb ~~ $step->{verb});
		print STDERR "rest_allowed ";
		my $engine = $engine_name->new(
			params => $step,
		);
		$engine->can('setup') && $engine->setup;
		print STDERR "can ";
		# See if plugin can data and do it. Break out if there's nothing returned
		$engine->can('data') && last unless $engine->data;
		print STDERR "executed ";
	}
	my $template_name = $c->node->endpath ?
		$recipe->{html_templates}{$c->node->endpath} :
		$recipe->{html_template};
	$template_name ||= $node->row->get_column('base_type');
	$c->response->template($c->config->jet->{template_path} . $template_name . $c->config->jet->{template_suffix});
	return;
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
