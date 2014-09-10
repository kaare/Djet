package Jet::Role::Treeview;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Treeview

=head1 DESCRIPTION

Returns the node information for the treeview

=head1 ATTRIBUTES

=cut

=head1 METHODS

=head2 to_json

Control what to send when it's JSON

=cut

before to_json => sub {
	my $self = shift;
	if (my ($template) = $self->request->parameters->{template} =~ /^tree(top|view)$/) {
		my $basenode = $self->basenode;
		my $dynadata;
		if ($template eq 'top') {
			my $folder = $basenode->has_children ? 1 : undef;
			$dynadata = [ {
				title => $basenode->title,
				folder => $folder,
				lazy => $folder,
				path => $basenode->node_path,
				id   => $basenode->node_id,
			} ];
		} else { # treeview
			my $node;
			if ($basenode->node_path =~ /index.html$/) {
				$node = $self->datanodes->[-2];
			} else {
				$node = $basenode;
			}
			$dynadata = [ map {
				my $folder = $_->has_children ? 1 : undef;
				{
					title => $_->part,
					path => $_->node_path,
					id   => $_->node_id,
					folder => $folder,
					lazy => $folder,
				}
			} $node->children ],
		}
		$self->stash->{dynadata} = $dynadata;
		$self->content_type('json');
		$self->renderer->set_expose_stash('dynadata');
		$self->omit_run->{all} = 1;
	}
};

no Moose::Role;

1;

# COPYRIGHT

__END__
