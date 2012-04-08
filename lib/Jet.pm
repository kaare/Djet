package Jet;

use 5.010;
use Moose;
use Plack::Request;
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
		$c->response->template('generic/error' . $c->config->jet->{template_suffix});
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
	my $node = $c->nodebox->find_node_path($req->path_info) || Jet::Exception->throw(NotFound => { message => $req->uri->as_string });
	$c->node($node);
	return $self->go($req, $node);
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
	$template_name ||= $node->get_column('base_type');
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
