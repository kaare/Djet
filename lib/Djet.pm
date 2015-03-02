package Djet;

use Moose;
use namespace::autoclean;

use Try::Tiny;

use Djet::Config;
use Djet::Failure;
use Djet::Machine;
use Djet::Navigator;

with qw/
	Djet::Part::Log
	Role::Pg::Notify
/;

use JSON;
use Plack::Request;
use Plack::Session::Store::DBI;

# ABSTRACT: A Modern Node-based Content Management System

=head1 NAME

Djet

=head1 DESCRIPTION

Djet is a Modern Content Management System. It's Node-based, which means that each path endpoint, as well as all the branch elements, is a Node.
What it takes to start a Djet

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

=head2 params

Djet parameters, from the environment

It's possible to set Djet attributes on the Command Line, e.g.

DJET_APP_ROOT=/somewhere/else starman

=cut

has params => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my %params = map {
			m/^djet_(.*)/i;
			my $key = lc $1;
			$key => lc $ENV{$_}
		} grep {/^djet_/i} keys %ENV;
		$params{configbase} //= 'etc/';
		return \%params;
	},
	lazy => 1,
);

=head2 config

Djet configuration

=cut

has config => (
	is => 'ro',
	isa => 'Djet::Config',
	default => sub {
		my $self = shift;
		return Djet::Config->new(%{ $self->params} );
	},
	lazy => 1,
);

=head2 model_name

The model_name is found in the config

=cut

has model_name => (
	isa => 'Str',
	is => 'ro',
	default => sub {
		my $self = shift;
		return $self->config->config->{model_name} || 'Djet::Model';
	},
	lazy => 1,
);

=head2 model

The model is initialized with the connection info found in the config

=cut

has model => (
	isa => 'Djet::Model',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $connect_info = $self->config->config->{connect_info};
		die 'No database connection information' unless $connect_info && @$connect_info;

		my $model_name = $self->model_name;
		eval "require $model_name" or die "No model named $model_name";

		my $model = $model_name->connect(@$connect_info);
		$model->config($self->config);
		return $model;
	},
	lazy => 1,
);

=head2 session_handler

The provider for web sessions

=cut

has session_handler => (
	isa => 'Plack::Session::Store',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $provider = Plack::Session::Store::DBI->new(
            dbh => $self->model->storage->dbh,
            serializer   => sub { JSON->new->allow_nonref->encode(shift); },
            deserializer => sub { JSON->new->allow_nonref->decode(shift); },
			table_name   => $self->config->config->{session}{table_name} // 'global.sessions',
        );
	},
	lazy => 1,
);

=head2 app

The thing that starts it all. Returns a Plack app

=cut

has app => (
	is => 'ro',
	isa => 'CodeRef',
	default => sub {
		my $self = shift;
		return sub {
			$self->check_notifications;
			my @args = @_;
			my $env = shift @args;
			my $session = $env->{'psgix.session'} // {};
			my $request = Plack::Request->new($env);

			my $model = $self->model;
			my $navigator = Djet::Navigator->new(
				model => $model,
				request => $request,
				session => $session,
			);
			$navigator->check_route;
			return $navigator->result if $navigator->has_result; # The navigator found a detour

			my $engine_class = $self->find_engine_class($navigator);
			return $engine_class if ref $engine_class eq 'ARRAY'; # There's a response already

			my $resource_args = [
				model => $self->model,
				env => $env,
				request => $request,
				navigator => $navigator,
				stash => {},
			];
			my $app = Djet::Machine->new(
				resource => $engine_class,
				resource_args => $resource_args,
				tracing => 1,
			);
			return $app->call($env);
		};
	},
	lazy => 1,
);

=head2 check_notifications

Check if there has been changes to the basenode

=cut

sub check_notifications {
	my $self = shift;
	my $note = $self->get_notification or return;

	my ($q, $pid, $payload) = @$note;
	my ($action, $subject, $id) = split ':', $payload;
	return unless $action eq 'reload' and $subject eq 'basetype';

	my $model = $self->model;
	my $basetypes = $model->basetypes;
	$basetypes->{$id} =  $model->resultset('Djet::Basetype')->find({id => $id});
}

=head2 find_engine_class

Finds the engine_class, given the navigator

=cut

sub find_engine_class {
	my ($self, $navigator) = @_;
	my $model = $self->model;
	my $engine_class;
	try {
		my $basenode = $navigator->basenode;
		my $engine_basetype = $basenode->basetype;
		$engine_class = $engine_basetype->handler || 'Djet::Engine::Default';
		$model->log->debug('Class: ' . $engine_basetype->name . ' found, using '. $engine_class);
	} catch {
		my $e = shift;
		die $e if blessed $e && ($e->can('as_psgi') || $e->can('code')); # Leave it to Plack

		debug($e);
		Djet::Failure->new(
			exception => $e,
			datanodes => $navigator->datanodes,
		);
	};
	return $engine_class;
}

=head2 BUILD

Listen to the djet:admin queue

=cut

sub BUILD {
	my $self = shift;
	$self->listen(queue => 'djet:admin');
}

=head2 _build_notify_dbh

Build the notify dbh from the model's storage.

Keeps Role::Pg::Notify happy.

=cut

sub _build_notify_dbh {
	my $self = shift;
	return $self->model->storage->dbh;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
