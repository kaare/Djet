package Jet;

use 5.010;
use Moose;
use namespace::autoclean;

use Try::Tiny;

extends 'Plack::Component';

use Jet::Basenode;
use Jet::Exception;
use Jet::Failure;
use Jet::Response;

with 'MooseX::Traits';
with 'Jet::Role::Log';

# ABSTRACT: A Modern Node-based Content Management System

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

sub call {
	my ($self) = @_;
	my $request = $self->request;
	my $stash  = {request => $request};
	my ($basenode, $response);
	try {
		$basenode = $self->basenode->find_basenode(path => $path);
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

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

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
