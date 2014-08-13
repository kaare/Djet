package Jet::Body;

use 5.010;
use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use HTTP::Headers::Util qw(split_header_words);
use Plack::Request;

with 'Jet::Role::Log';

=head1 NAME

Jet::Body - The Jet Body

=head1 DESCRIPTION

Jet::Body is instantiated by Jet::Starter at the beginning of a request cycle.
It holds all the volatile information, as opposed to Jet::Config.


=head1 ATTRIBUTES

=head2 env

The web environment

=cut

has env => (
	is => 'ro',
	isa => 'HashRef',
);

=head2 request

The plack request

=cut

has request => (
	is => 'ro',
	isa => 'Plack::Request',
	default => sub {
		my $self = shift;
		return Plack::Request->new($self->env);
	},
	lazy => 1,
);

=head2 stash

The stash keeps data throughout a request cycle

=cut

has stash => (
	isa => 'HashRef',
	traits => ['Hash'],
	is => 'ro',
	lazy => 1,
	default => sub { {} },
	handles => {
		set_stash => 'set',
		clear_stash => 'clear',
	},
);

=head2 datanodes

The node stack found

=cut

has datanodes => (
	isa => 'ArrayRef[Jet::Schema::Result::Jet::DataNode]',
	is => 'ro',
	writer => '_set_datanodes',
);

=head2 basenode

The node we're working on

=cut

has basenode => (
	isa => 'Jet::Schema::Result::Jet::DataNode',
	is => 'ro',
	writer => '_set_basenode',
);

=head1 METHODS

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
