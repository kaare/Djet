package Djet::Model;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;

use Text::CleanFragment;

extends 'Djet::Schema';

use Djet::ACL;
use List::Util qw/first/;

=head1 NAME

Djet::Model

=head1 DESCRIPTION

Djet::Model extends Djet::Schema, which itself extends DBIx::Class.

The Djet Model is a model of the World, as seen from Djet. It builds on the Djet Schema and includes configuration, acl, payload attributes, and more.

Djet::Model is instantiated for every server process, or, in case it's not running in a web environment, it is instantiated upon startup.

There are a number of volatile attributes:

	env
	navigator
	payload
	request
	session
	session_id
	stash

Whenever the web server processes a request, these volatile attributes are cleared and set to the new value.
This happens only one place in the request cycle.

=head1 ATTRIBUTES

=head2 config

Djet configuration. Djet::Model wants to know its surroundings upon start.

=cut

has config => (
	is => 'rw',
	isa => 'Djet::Config',
	handles => [qw/
		renderers
		log
	/],
);

=head2 acl

The acl class

=cut

has acl => (
	is => 'ro',
	isa => 'Djet::ACL',
	default => sub {
		my $self = shift;
		my $acl = Djet::ACL->new(
			roles_dbh => $self->storage->dbh,
		);
		return $acl;
	},
	lazy => 1,
);

=head2 basetypes

Djet Basetypes

=cut

has basetypes => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		return { map { $_->id =>  $_} $self->resultset('Djet::Basetype')->search };
	},
	lazy => 1,
);

=head2 payload_class

The payload class is put on the stash

=cut

has payload_class => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $payload_class = $self->config->{config}{djet_config}{payload_class} || 'Djet::Payload';
		$self->log->debug("Payload Class: $payload_class");
		eval "require $payload_class";
		$self->log->debug($@) if $@; # The logical thing would be to die, but we're in Web::Machine country, and it seems to eat it up

		return $payload_class;
	},
	lazy => 1,
);

=head1 VOLATILE ATTRIBUTES

=head2 env

The web environment

=cut

has 'env' => (
	is => 'ro',
	isa => 'HashRef',
	trigger => sub {
		my $self = shift;
		$self->_clear_http_host;
		$self->_clear_session;
		$self->_clear_session_id;
		$self->_clear_request;
		$self->_clear_navigator;
		$self->_clear_payload;
		$self->_clear_stash;
	},
	writer => '_set_env',
);

=head2 http_host

http host could be (would be) set in the front web server (e.g. nginx) and should point to the 
actual requested host.

=cut

has 'http_host' => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $env = $self->env;
		return $env->{'HTTP_HOST'} // '';
	},
	lazy => 1,
	clearer => '_clear_http_host',
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
	clearer => '_clear_session',
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
	clearer => '_clear_session_id',
	predicate => 'has_session_id',
);

=head2 request

The plack request

=cut

has 'request' => (
	is => 'ro',
	isa => 'Plack::Request',
	default => sub {
		my $self = shift;
		return Plack::Request->new($self->env);
	},
	lazy => 1,
	clearer => '_clear_request',
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
	default => sub {
		my $self = shift;
		my $navigator = Djet::Navigator->new(
			model => $self,
		);
	},
	lazy => 1,
	clearer => '_clear_navigator',
);

=head2 payload

The plack payload

=cut

has payload => (
	is => 'ro',
	isa => 'Djet::Payload',
	default => sub {
		my $self = shift;
		return $self->payload_class->new(
			model => $self,
		);
	},
	lazy => 1,
	clearer => '_clear_payload',
);

=head2 stash

The stash keeps data throughout a request cycle

=cut

has stash => (
	isa => 'HashRef',
	traits => ['Hash'],
	is => 'ro',
	default => sub { {} },
	lazy => 1,
	handles => {
		'set_stash' => 'set',
		'_clear_stash' => 'clear',
	},
);


=head1 METHODS

=head2 basetype_by_name

Returns a basetype from the cache, given a name

=cut

sub basetype_by_name {
	my ($self, $basename) = @_;
	return first {$_->name eq $basename} values %{ $self->basetypes };
}

=head2 normalize_part

Take some text and make a nice part out of it


=cut

sub normalize_part {
	my ( $self, $text ) = @_;
	return join("_", clean_fragment($text));
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
