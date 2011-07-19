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
	$self->handle_request($env);
	return [ $c->response->status, $c->response->headers, $c->response->output ];
}

=head2 handle_request

=cut

sub handle_request($) {
	my ($self, $env) = @_;
	my $req = Plack::Request->new($env);
	my $node = $self->find_node($req->uri) || return $self->page_notfound($req->uri);

	my $engine = Jet::Engine->new(
		request => $req,
		node => $node,
	);

	return $self->go($req, $node);
}

=head2 find_node

Accepts an url and returns a Jet::Node if the url points to a valid path in the system.

If not found, it goes one step up from find_node and tries to find something consistent with the path

=cut

sub find_node($) {
	my ($self, $uri) = @_;
	my $c = Jet::Context->instance;
	my $node_path = [split('/', $uri->path) || ''];
	my $nodedata = $c->schema->find_node({ node_path =>  $node_path });
	return Jet::Node->new(result => $nodedata) if $nodedata;

	# Find node at one level up. See if there is a path expression on that node
	my $endpath = pop @$node_path;
	$nodedata = $c->schema->find_node({ node_path =>  $node_path });
	return unless $nodedata and $self->node_path_match($nodedata, $endpath);

## Find path data on the node and see if it matches. ## 
	return Jet::Node->new(result => $nodedata);
}

=head2 node_path_match

Check a node and see if there is a match for the given "extra" path

=cut

sub node_path_match {
	my ($self, $nodedata, $endpath) = @_;
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
	my ($self, $req, $node) = @_;
	my $c = Jet::Context->instance(node => $node);
	my $code;
	$code = $node->can('init') && $code;
	$code = $node->can('data') && $code;
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
