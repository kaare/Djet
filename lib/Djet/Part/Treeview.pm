package Djet::Part::Treeview;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Treeview

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
		my $domain_basetype = $self->model->basetype_by_name('domain');
		my $domain_node = $self->datanode_by_basetype($domain_basetype);
		my $local = $self->stash->{local};
		my $dynadata;
		if ($template eq 'top') {
			my $folder = $domain_node->has_children ? 1 : undef;
			my $path = $local->urify;
			$dynadata = [ {
				title => $domain_node->title,
				folder => $folder,
				lazy => $folder,
				path => $path,
				id   => $domain_node->node_id,
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
				my $path = $local->urify($_);
				{
					title => $_->part,
					path => $path,
					id   => $_->node_id,
					folder => $folder,
					lazy => $folder,
				}
			} $node->children ],
		}
		$self->stash->{dynadata} = $dynadata;
		$self->content_type('json');
		$self->renderer->set_expose_stash('dynadata');
	}
};

no Moose::Role;

1;

# COPYRIGHT

__END__
