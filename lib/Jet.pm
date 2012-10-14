package Jet;

use 5.010;
use Moose;
use Try::Tiny;

use Jet::Basenode;
use Jet::Engine;
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
	my $response = Jet::Response->new(
		stash  => $stash,
		renderers => $request->renderers,
	);
	my $basenode;
	try {
		$basenode = $self->find_node_path($stash);
		# Set a default html template if there are no arguments. We should probably look for response type to determine if it's a REST request first though
		my $jet_config = $request->config->jet;
		$response->template($jet_config->{template_path} . $basenode->get_column('node_path') . $jet_config->{template_suffix}) unless @{ $basenode->arguments};
	} catch {
		my $e = shift;
		Jet::Failure->new(
			exception => $e,
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
	my ($self, $stash) = @_;
	my $request = $self->request;
	my $path = $request->request->path_info;
	$path =~ s|^(.*?)/?$|$1|; # Remove last character if slash
	my %nodeparams = (
		schema => $request->schema,
		basetypes => $request->basetypes,
	);
	my $nodedata = $request->schema->find_basenode($path);
	Jet::Exception->throw(NotFound => { message => $path }) unless $nodedata;

	my $basedata = shift @$nodedata;
	# Find the path arguments
	my $basepath = $basedata->{node_path};
	$path =~ /$basepath(.*)/;
	my @arguments = split '/', $1;
	shift @arguments;
	# Save the remaining nodes on the stash
	$stash->{nodes}{$_->{node_id}} = Jet::Node->new(row => $_, stash => $stash) for @$nodedata;

	my $baserole = $request->basetypes->{$basedata->{basetype_id}}->node_role;
	return $baserole ?
		Jet::Basenode->with_traits($baserole)->new(%nodeparams, row => $basedata, arguments => \@arguments, stash => $stash) :
		Jet::Basenode->new(%nodeparams, row => $basedata, stash => $stash);
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
