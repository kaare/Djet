package Jet;

use 5.010;
use Moose;
use Plack::Request;
use Jet::Engine;
use Jet::Node;
use Jet::Context;

use Data::Dumper;

sub run_psgi($) {
	my ($self, $env) = @_;
	my $headers = [ 'Content-Type' => 'text/html; charset="utf-8"' ];
	my ($status, $response) = $self->handle_request($env);
	return [ $status, $headers, $response || [] ];
}

sub handle_request($) {
	my ($self, $env) = @_;
	my $req = Plack::Request->new($env);
	return $self->page_notfound($req->uri) unless
		my $node = $self->find_node($req->uri)
		||  $self->node_notfound($req->uri);

	my $engine = Jet::Engine->new(
		request => $req,
		node => $node,
	);

	return $self->go($req, $node);
}

sub find_node($) {
	my ($self, $uri) = @_;
	my $c = Jet::Context->instance;
	my $node_path = [split '/', $uri->path];
	$node_path = [""] unless @$node_path;
	my $node = $c->schema->find_node({ node_path =>  $node_path });
	return Jet::Node->new(node => $node);
}

sub node_notfound($) {
	my ($self, $uri) = @_;
	my $c = Jet::Context->instance;
	my $node_path = [split '/', $uri->path];
	$node_path = [''] unless @$node_path;
	pop @$node_path;
	my $node = $c->schema->resultset('Nodepath')->find({ node_path => { -value => $node_path } });
## Find path data on the node and see if it matches. ## 
	return Jet::Node->new($node);
}

sub page_notfound($) {
	my ($self, $uri) = @_;
	return 404;
}

sub go {
	my ($self, $req, $node) = @_;
	my $c = Jet::Context->instance(module => $node->basetype);
	my $status = 200;

	my $query = $req->param('query');
	my $body = $req->body;
#	my $recipe = $c->recipe;
$body = [qw/test/];
	return $status, $body;
}

__PACKAGE__->meta->make_immutable;

1;
__END__
=head1 NAME

Jet - Faster than an AWE2

=head1 SYNOPSIS

Experimental module

=head1 ATTRIBUTES

=head1 METHODS

=head2 run_psgi

=head2 handle_request

=head2 find_node

Accepts an url and returns a Jet::Node if the url points to a valid path in the system.

=head2 node_notfound

Goes one step up from find_node and tries to find something consistent with the path

=head2 page_notfound

Returns 404 per default