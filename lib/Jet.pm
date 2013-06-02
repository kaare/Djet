package Jet;

use 5.010;
use Moose;
use namespace::autoclean;

use Try::Tiny;

use Jet::Basenode;
use Jet::Exception;
use Jet::Failure;
use Jet::Response;

with 'MooseX::Traits';
with 'Jet::Role::Log';

# ABSTRACT: A Modern Content Management System

=head1 NAME

Jet

=head1 DESCRIPTION

Faster than an AWE2

=head1 SYNOPSIS

Experimental CMS

=head1 ATTRIBUTES

=cut

has request => (
	is => 'ro',
	isa => 'Jet::Request',
);

=head1 METHODS

=head2 run_psgi

Entry point from psgi

=cut

sub run_psgi($) {
	my ($self) = @_;
	my $request = $self->request;
	my $stash  = {request => $request};
	my ($basenode, $response);
	try {
		$basenode = $self->find_node_path($stash);
		$response = Jet::Response->new(
			stash  => $stash,
			renderers => $request->renderers,
			template => $basenode->basetype->template,
		);
		my $engine_class = $basenode->basetype->class;
		my $engine = $engine_class->new(
			stash => $stash,
			request => $self->request,
			basenode => $basenode,
			response => $response,
		);
		$engine->init;
		$engine->data;
		$engine->render;
		$response->render;
	} catch {
		my $e = shift;
		debug($e);
		Jet::Failure->new(
			exception => $e,
			request => $request,
			basenode => $basenode,
			stash  => $stash,
			response => $response,
		);
	};
	return [ $response->status, $response->headers, $response->output ];
}

=head2 find_node_path

Accepts an url and returns a Jet::Basenode if the url points to a valid path in the system.

=cut

sub find_node_path($) {
	my ($self, $stash) = @_;
	my $request = $self->request;
	my $path = $request->request->path_info;
	$path =~ s|^(.*?)/?$|$1|; # Remove last character if slash
	my $nodedata;
	$nodedata = $request->schema->find_basenode({ node_path => $path });

	# Try again to see if the last part was a parameter
	if (!$nodedata) {
		my @segments = $request->request->uri->path_segments;
		my $argument = pop @segments;
		$nodedata = $request->schema->find_basenode({ node_path => join '/', @segments });
		Jet::Exception->throw(NotFound => { message => $path }) unless $nodedata;
		$request->set_arguments([$argument // '']);
	}
# Replace the next line with the shift when find_basenode is updated (see below)
	my $basedata = $nodedata;
	# my $basedata = shift @$nodedata;
	my %nodeparams = (
		schema => $request->schema,
		basetype => $request->basetypes->{$basedata->{basetype_id}},
	);
	# Save the remaining nodes on the stash
# Reenable this when find_basenode returns an array w/ the basenode and all ancestors again
#	$stash->{nodes}{$_->{node_id}} = Jet::Node->new(row => $_, stash => $stash) for @$nodedata;
	return Jet::Basenode->new(%nodeparams, row => $basedata);
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
