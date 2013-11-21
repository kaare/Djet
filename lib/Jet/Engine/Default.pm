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
	isa		=> 'ArrayRef',
	parts => [
		{'Jet::Part::Basenode' => 'jet_basenode'},
		{
			module => 'Jet::Part::Children',
			alias  => 'jet_children',
			type => 'json',
		},
	],
);

=head1 METHODS

=head2 set_renderer

Control what to send when it's JSON

=cut

after set_renderer => sub {
	my $self = shift;
	my $response = $self->response;
	if ($response->type =~ /json/i and my ($template) = $self->request->request->parameters->{template} =~ /^tree(top|view)$/) {
		my $basenode = $self->basenode;
		my $dynadata;
		if ($template eq 'top') {
			my $folder = $basenode->has_children ? 1 : undef;
			$dynadata = [ {
				title => $basenode->title,
				folder => $folder,
				lazy => $folder,
				path => $basenode->node_path,
			} ];
		} else { # treeview
			$dynadata = [ map {
				my $folder = $_->has_children ? 1 : undef;
				{
					title => $_->part,
					path => $_->node_path,
					folder => $folder,
					lazy => $folder,
				}
			} $basenode->nodes ],
		}
		$self->set_stash('dynadata', $dynadata);
		$response->renderer->set_expose_stash('dynadata');
	}
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
