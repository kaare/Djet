package Jet::Engine::Default;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Log/;

=head1 NAME

Jet::Engine - Default Jet Engine

=head1 DESCRIPTION

Jet::Engine::Default is the basic Jet Engine.

=head1 ATTRIBUTES

=head2 parts

This is the engine parts

=cut

has _parts => (
	traits	=> [qw/Jet::Trait::Engine/],
	is		=> 'ro',
	isa	   => 'ArrayRef',
	parts => [
		{'Jet::Part::Basenode' => 'jet_basenode'},
		{
			module => 'Jet::Part::Children',
			alias  => 'jet_children',
			type => 'json',
		},
	],
);

no Moose;

=head1 METHODS

=head2 render

Control what to send when it's JSON

=cut

sub render {
	my $self = shift;
	if ($self->response->type =~ /json/i) {
		$self->clear_stash;
		my $basenode = $self->basenode;
		my @dynadata = map {{title => $_->part, isfolder => 1}}  $basenode->nodes;
		$self->set_stash('dynadata', \@dynadata);
	}
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
