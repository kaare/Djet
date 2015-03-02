package Djet::Part::Basic;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Basic

=head1 DESCRIPTION

The basic attributes for Djet classes.

=head1 ATTRIBUTES

There are two kinds of attribute. The one following the server process, the model.

And the ones following the request.

=head2 model

The Djet model. The model extends L<Djet::Schema>, but there are also accessors for configuration, basetypes, renderers and log

=cut

has model => (
	is => 'ro',
	isa => 'Djet::Model',
	handles => [qw/
		acl
		basetypes
		config
		log
		renderers
	/],
);

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
	default => sub {
		my $self = shift;
		my $env = $self->env;
		return $env->{'psgix.session'} // {};
	},
	lazy => 1,
);

=head2 session_id

The session

=cut

has session_id => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $env = $self->env;
		my $options = $env->{'psgix.session.options'} or return 0 ;
		return exists $options->{id} ? $options->{id} : 0,
	},
	lazy => 1,
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

no Moose::Role;

1;

# COPYRIGHT

__END__
