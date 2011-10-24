package Jet::Context::Config;

use 5.010;
use Moose;

use Config::Any;

with 'Jet::Role::Log';

has config => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $config_total = Config::Any->load_files({
			files => [glob 'etc/*'],
			use_ext => 1,
			flatten_to_hash => 1,
		});
		return $config_total;
	},
);
has jet => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		return $self->config->{'etc/jet.conf'};
	},
);
has options => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		return $self->config->{'etc/options.conf'};
	},
);

sub private {
	my ($self, $module) = @_;
	return {};
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

Jet::Context::Config - Jet Configuration

=head1 SYNOPSIS

=head1 Attributes

=head2 config

Jet's configuration, loaded from config files
