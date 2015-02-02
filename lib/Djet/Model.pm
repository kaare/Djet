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

The Djet Model is a model of the World, as seen from Djet. It builds on the Djet Schema and includes configuration, acl, and payload attributes, and more.

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

=head2 local_class

The local class is put on the stash

=cut

has local_class => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $local_class = $self->config->{config}{djet_config}{local_class} || 'Djet::Local';
		$self->log->debug("local Class: $local_class");
		eval "require $local_class";
		warn $@ if $@; # The logical thing would be to die, but we're in Web::Machine country, and it seems to eat it up

		return $local_class;
	},
	lazy => 1,
);

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
