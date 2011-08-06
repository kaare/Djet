package Jet;

use 5.010;
use Moose;
use Plack::Request;
use Jet::Engine;
use Jet::Node;
use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet - Faster than an AWE2

=head1 SYNOPSIS

Experimental module

=head1 ATTRIBUTES

=head1 METHODS

=head2 run_psgi

=cut

sub run_psgi($) {
	my ($self, $env) = @_;
	my $c = Jet::Context->instance;
	# Clear request specific attributes
	$c->clear;

	$self->handle_request($env);
	$c->response->render;
	return [ $c->response->status, $c->response->headers, $c->response->output ];
}

=head2 handle_request

=cut

sub handle_request($) {
	my ($self, $env) = @_;
	my $c = Jet::Context->instance;
	my $req = Plack::Request->new($env);
	$c->_request($req);
	my $node = $self->find_node($req->uri) || return $self->page_notfound($req->uri);

	$c->node($node);
	return $self->go($req, $node);
}

=head2 find_node

Accepts an url and returns a Jet::Node if the url points to a valid path in the system.

If not found, it goes one step up from find_node and tries to find something consistent with the path

=cut

sub find_node($) {
	my ($self, $uri) = @_;
	my $c = Jet::Context->instance;
	my $schema = $c->schema;
	my $node_path = [split('/', $uri->path)] || [''];
	$node_path = [''] unless @$node_path;
	my $nodedata = $schema->find_node({ node_path =>  $node_path });
	return Jet::Node->new(
		row => $nodedata,
	) if $nodedata;

	# Find node at one level up. See if there is a path expression on that node
	my $endpath = pop @$node_path;
	$nodedata = $c->schema->find_node({ node_path =>  $node_path });
	return unless $nodedata and $self->node_path_match($nodedata, $endpath);

## XXX Find path data on the node and see if it matches. ## 
## noget a la if $self->match_path($nodedata, $endpath)
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

=head2 page_notfound

Returns 404 per default

=cut

sub page_notfound($) {
	my ($self, $uri) = @_;
	my $c = Jet::Context->instance;
	$c->response->status(404);
}

=head2 go

Does the actual data processing and rendering for this node

=cut

sub go {
	my ($self, $req) = @_;
	my $c = Jet::Context->instance;
	my $node = $c->node;
	my $recipe = $c->recipe;
# XXX
	my $steps = $c->node->endpath ? 
		$recipe->{paths}{$c->node->endpath} :
		$recipe->{steps};
# XXX
	for my $step (@$steps) {
		my $plugin_name = "Jet::Plugin::$step->{plugin}";
		eval "require $plugin_name" or next;

		my $plugin = $plugin_name->new(
			in => $step->{in},
		);
		$plugin->can('setup') && $plugin->setup;
		$plugin->can('data') && $plugin->data;
	}
# XXX
	return;
}

__PACKAGE__->meta->make_immutable;

1;
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
