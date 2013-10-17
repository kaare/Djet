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

=head2 serializer

The response serializer.

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

=head1 METHODS

=head2 render

Renders the output as JSON

=cut

sub render {
	my ($self, $template, $stash) = @_;
	warn 'Rendering ' . $template;
my @dynadata = map {{title => $_->row->{part}, isFolder => 1}}  @{$stash->{basenode}->children };
use Data::Dumper;
warn Dumper \@dynadata;
	return $self->json->encode(\@dynadata);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
