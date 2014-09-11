package Jet::Starter;

use Moose;

use Jet;
use Jet::Config;
use Jet::Body;
use Jet::Machine;

with 'Role::Pg::Notify';

=head1 NAME

Jet::Starter

=head1 DESCRIPTION

What it takes to start a Jet

=head1 ATTRIBUTES

=head2 params

Jet parameters, from the environment

=cut

has params => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my %params = map {
			m/^jet_(.*)/i;
			my $key = lc $1;
			$key => lc $ENV{$_}
		} grep {/^jet_/i} keys %ENV;
		$params{configbase} //= 'etc/';
		return \%params;
	},
	lazy => 1,
);

=head2 config

Jet configuration

=cut

has config => (
	is => 'ro',
	isa => 'Jet::Config',
	default => sub {
		my $self = shift;
		return Jet::Config->new(%{ $self->params} );
	},
	lazy => 1,
);

=head2 schema

The schema is initialized with the connection info found in the config

=cut

has schema => (
   isa => 'Jet::Schema',
   is => 'ro',
   default => sub {
	   my $self = shift;
	   my $connect_info = $self->config->config->{connect_info};
	   die 'No database connection information' unless $connect_info && @$connect_info;

	   my $schema = Jet::Schema->connect(@$connect_info);
	   $schema->config($self->config);
	   return $schema;
	},
	lazy => 1,
);

=head2 app

The thing that starts it all

=cut

has app => (
	is => 'ro',
	isa => 'CodeRef',
	default => sub {
		my $self = shift;
		return sub {
			$self->check_notifications;
			my $env = shift;
			my $body = Jet::Body->new(
				env => $env,
				stash => {},
			);
			my $flight = Jet->new(body => $body, schema => $self->schema);
			my $engine = $flight->take_off(@_);
			my $resource_args = [
				body => $body,
				schema => $self->schema,
			];
			my $app = Jet::Machine->new(
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

	my $schema = $self->schema;
	my $basetypes = $schema->basetypes;
	$basetypes->{$id} =  $schema->resultset('Jet::Basetype')->find({id => $id});
}

=head2 BUILD

Listen to the jet:admin queue

=cut

sub BUILD {
	my $self = shift;
	$self->listen(queue => 'jet:admin');
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
