package Djet::Body::Base;

use 5.010;
use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use HTTP::Headers::Util qw(split_header_words);
use Plack::Request;

with 'Djet::Part::Log';

=head1 NAME

Djet::Body::Base

=head1 DESCRIPTION

The Djet Body Base Class

Djet::Body is instantiated by Djet::Starter at the beginning of a request cycle.
It holds all the volatile information, as opposed to Djet::Model.

=head1 ATTRIBUTES

=head2 env

The web environment

=cut

has env => (
	is => 'ro',
	isa => 'HashRef',
);

=head2 session

The session

=cut

has session => (
	is => 'ro',
	isa => 'HashRef',
);

=head2 session_id

The session

=cut

has session_id => (
	is => 'ro',
	isa => 'Str',
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

=head2 navigator

The plack navigator

=cut

has navigator => (
	is => 'ro',
	isa => 'Djet::Navigator',
	handles => [qw/
		basenode
		datanodes
		datanode_by_basetype
		rest_path
		raw_rest_path
	/],
	writer => 'set_navigator',
);

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
