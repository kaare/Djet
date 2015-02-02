package Djet::Starter;

use Moose;

use Djet;
use Djet::Config;
use Djet::Body;
use Djet::Machine;

with 'Role::Pg::Notify';

use JSON;
use Plack::Session::Store::DBI;

=head1 NAME

Djet::Starter

=head1 DESCRIPTION

What it takes to start a Djet

=head1 ATTRIBUTES

=head2 params

Djet parameters, from the environment

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
			my $options = $env->{'psgix.session.options'} // {};
			my $body = Djet::Body->new(
				env => $env,
				session => $session,
				session_id => $options->{id} // 0,
				stash => {},
			);
			my $flight = Djet->new(body => $body, model => $self->model);
			my $engine = $flight->take_off(@_);
			return $engine if ref $engine eq 'ARRAY'; # There's a response already

			my $resource_args = [
				body => $body,
				model => $self->model,
			];
			my $app = Djet::Machine->new(
				resource => $engine,
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

=head2 BUILD

Listen to the djet:admin queue

=cut

sub BUILD {
	my $self = shift;
	$self->listen(queue => 'djet:admin');
}

=head2 _build_notify_dbh

Build the notify dbh from the model's storage.

=cut

sub _build_notify_dbh {
	my $self = shift;
	return $self->model->storage->dbh;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
