package Djet::Payload;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

with qw/
	Djet::Part::Basic
	Djet::Part::Generic::Urify
/;

=head1 NAME

Djet::Payload

=head1 DESCRIPTION

Djet::Payload is a base class for payload_class.

The purpose of this is to have a class that is put on the stash and that can contain
anything you'd like.

A good idea is to have lazy attributes which will only be used if necessary.

=head1 ATTRIBUTES

See L<Djet::Part::Basic>

=head2 query_parameters

The query parameters, less the page stuff

=cut

has 'query_parameters' => (
	is => 'ro',
	isa => 'Hash::MultiValue',
	default => sub {
		my $self = shift;
		my $query_parameters = $self->model->request->query_parameters;
		delete $query_parameters->{page};
		return $query_parameters;
	},
	lazy => 1,
);

=head2 flash

The flash data from the session

=cut

has 'flash' => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		my $token = $self->model->request->param('flash') || return {};

		return delete $self->model->session->{flash}{$token} // {};
	},
	lazy => 1,
);

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

