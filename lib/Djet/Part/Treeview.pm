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
	my $model = $self->model;
    my $parameters = $model->request->parameters;
	if (my ($template) = $parameters->{template} =~ /^tree(top|view)$/) {
        my $path = $parameters->{path} // '/';
       my $find = {
            node_path => {'@>' => $path},
        };
        my $options = {
           order_by => { -desc => \'length(node_path)' },
           rows => 1,
       };
        my $node = $model->resultset('Djet::DataNode')->search($find, $options)->first;
		my $child_data = [ map {
			my $child = {
				title => $_->title,
				path => $_->node_path,
				id   => $_->node_id,
			};
            $child->{children} = [{}] if $_->has_children;
            $child
		} $node->children ];
		$model->stash->{data} = {
            title => $node->title,
            path => $node->node_path,
            children => $child_data,
        };
		$self->content_type('json');
		$self->renderer->set_expose_stash('data');
	}
};

no Moose::Role;

1;

# COPYRIGHT

__END__
