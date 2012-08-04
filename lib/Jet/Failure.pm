package Jet::Failure;

use 5.010;
use Moose;

=head1 NAME

Jet::Failure - Something bad happened to our Jet

=head1 SYNOPSIS

Jet::Failure handles the case when the Jet won't fly


=head1 ATTRIBUTES

=cut

has exception => (
	isa => 'Str|Jet::Exception',
	is => 'ro',
	trigger => sub {
		my ($self, $e) = @_;
		my $stash = $self->stash;
		if (ref $_) {
			$stash->{exception} = $e
		} else {
			$stash->{error} = $e
		}
		my $response = $self->response;
		$response->template('generic/error' . $self->config->jet->{template_suffix});
		$response->render;
	},
);
has config => (
	isa => 'Jet::Config',
	is => 'ro',
);
has schema => (
	isa => 'Jet::Stuff',
	is => 'rw',
);
has cache => (
	isa => 'Object',
	is => 'ro',
);
has basetypes => (
	isa       => 'HashRef',
	is        => 'ro',
);
has stash => (
	isa => 'HashRef',
	is => 'ro',
);
has request => (
	isa => 'Plack::Request',
	is => 'ro',
);
has basenode => (
	isa => 'Jet::Basenode',
	is => 'ro',
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

1;
__END__

