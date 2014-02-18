package Jet::Starter;

use Moose;

use Jet;
use Jet::Config;
use Jet::Request;

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
			my $env = shift;
			my $request = Jet::Request->new(
				env => $env,
				schema => $self->schema,
			);
			my $flight = Jet->new(request => $request);
			$flight->take_off(@_);
		};
	},
	lazy => 1,
);

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
