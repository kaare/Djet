package Jet::Role::Treeview;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Treeview - handle treeview

=head1 ATTRIBUTES

=cut

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

no Moose::Role;

1;

# COPYRIGHT

__END__
