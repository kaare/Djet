package Djet;

use 5.010;
use Moose;
use namespace::autoclean;

use Try::Tiny;

use Djet::Navigator;
use Djet::Failure;
use Djet::Response;

with 'Djet::Part::Log';

# ABSTRACT: A Modern Node-based Content Management System

=head1 NAME

Djet

=head1 DESCRIPTION

Djet is a Modern Content Management System. It's Node-based, which means that each path endpoint, as well as all the branch elements, is a Node.

Djet builds on top of the most awesome technology known to Mankind:

 - Advanced PostgreSQL features
 - Plack
 - Moose
 - DBIx::Class
 - Web::Machine

Just to name a few.

=head1 TAGLINE

A Djet is faster than an AWE2

=head1 ATTRIBUTES

=head2 body

The body of the djet

=cut

has body => (
	is => 'ro',
	isa => 'Djet::Body',
);

=head2 schema

The schema

=cut

has schema => (
	is => 'ro',
	isa => 'Djet::Schema',
);

=head1 METHODS

=head2 take_off

Process the request.  Entry point from psgi

=cut

sub take_off {
	my ($self) = @_;
	my $body = $self->body;
	my $schema = $self->schema;
	my $navigator = Djet::Navigator->new(
		schema => $schema,
		request => $body->request,
		session => $body->session,
	);
	$navigator->check_route;
	return $navigator->result if $navigator->has_result;

	$body->set_navigator($navigator);
	my $basenode = $navigator->basenode;
	my $engine_class;
	try {
		my $engine_basetype = $basenode->basetype;
		$engine_class = $engine_basetype->handler || 'Djet::Engine::Default';
		$schema->log->debug('Class: ' . $engine_basetype->name . ' found, using '. $engine_class);
	} catch {
		my $e = shift;
		die $e if blessed $e && ($e->can('as_psgi') || $e->can('code')); # Leave it to Plack

		debug($e);
		Djet::Failure->new(
			exception => $e,
			body => $body,
			datanodes => $navigator->datanodes,
		);
	};
	return $engine_class;
}

=head2 login

Redirect to the login page

=cut

sub login {
	my ($self, $datanodes, $config, $original_path) = @_;
	$self->body->session->{redirect_uri} = $original_path;
	my $uri = '/login';
	return [ 302, [ Location => $uri ], [] ];
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
