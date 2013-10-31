package Jet::Render::Json;

use 5.010;
use Moose;
use namespace::autoclean;

use JSON;

with 'Jet::Role::Log';

=head1 NAME

Jet::Render::Json - Render json for Jet

=head1 DESCRIPTION

This is the Json class for L<Jet>.

=head1 ATTRIBUTES

=head2 json

The response serializer. Probably no need to set it; defaults to JSON->new->pretty.

=cut

has json => (
	isa => 'JSON',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return JSON->new->pretty;
	},
);

=head2 expose_stash


=cut

has expose_stash => (
	isa => 'Str|ArrayRef|RegexpRef',
	is => 'ro',
	predicate => '_has_expose_stash',
	writer => 'set_expose_stash',
);

=head1 METHODS

=head2 render

Renders the output as JSON

=cut

sub render {
	my ($self, $template, $stash) = @_;
	my $cond = sub { 1 };
	my $single_key;
	if ($self->_has_expose_stash) {
		my $expose = $self->expose_stash;
		if (ref($expose) eq 'Regexp') {
			$cond = sub { $_[0] =~ $expose };
		} elsif (ref($expose) eq 'ARRAY') {
			my %match = map { $_ => 1 } @$expose;
			$cond = sub { $match{$_[0]} };
		} elsif (!ref($expose)) {
			$single_key = $expose;
		} else {
# FIXME			$c->log->warn("expose_stash should be an array referernce or Regexp object.");
		}
	}

	my $data;
	if ($single_key) {
		$data = $stash->{$single_key};
	} else {
		$data = { map { $cond->($_) ? ($_ => $stash->{$_}) : () } keys %{$stash} };
	}

	return $self->json->encode($data);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
