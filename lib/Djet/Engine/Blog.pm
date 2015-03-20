package Djet::Engine::Blog;

use 5.010;
use Moose;

use DateTime;

extends 'Djet::Engine::Children';
with qw/
	Djet::Part::Flash
	Djet::Part::Update::Node
/;

=head1 NAME

Djet::Engine::Blog

=head2 DESCRIPTION

Blog handling

=head1 METHODS

=head2 before init_data

Set the list name to 'blogs'. Only when viewing blog list.

=cut

before 'init_data' => sub  {
	my $self = shift;
	my $model = $self->model;
	my $basetype = $model->basetype_by_name('blog') or die "No basetype: blog";
	if ($model->basenode->basetype_id == $basetype->id) { # Single blog; no list
		$self->set_list_name('comments');
		$self->add_options(order_by => {'-asc' => 'node_created'});

		my $blog_reply_type = $model->basetype_by_name('blog_reply') or die "No basetype: blog_reply";

		$model->stash->{blog_reply} = $model->resultset('Djet::DataNode')->new({
			basetype_id => $blog_reply_type->id,
			parent_id => $model->basenode->id,
			datacolumns => {}
		});
		return;
	}

	$self->set_list_name('blogs');
	$self->add_search("datacolumns->>'status'" => [qw/published scheduled/]);
	$self->add_search("datacolumns->>'publish_date'" => {'<=' => DateTime->now->ymd});
	$self->add_options(order_by => {'-desc' => "datacolumns->>'publish_date'"});
};

=head2 before set_base_object

Will create a new empty blog reply if it's a "parent" (blog) basetype.

=cut

after 'set_base_object' => sub  {
	my $self = shift;
	my $model = $self->model;
	my $blog_reply;
	if ($model->request->method eq 'POST') {
		my $blog_reply_type = $model->basetype_by_name('blog_reply') or die "No basetype: blog_reply";
		$blog_reply = $model->resultset('Djet::DataNode')->new({
			basetype_id => $blog_reply_type->id,
			parent_id => $model->basenode->id,
			datacolumns => {}
		});
		$self->set_object($blog_reply);
		$self->is_new(1);
	}
	$model->stash->{blog_reply} = $blog_reply;
};

=head2 before get_input_data

Add a name and a title

=cut

before 'get_input_data' => sub {
	my ($self, $validation)=@_;
	$validation->valid->{name} = 'Blog Reply';
	$validation->valid->{title} = $validation->valid->{name};
};

=head2 create_path

Redirect to the blog post

=cut

sub create_path {
	my ($self, $validation)=@_;
	my $blog_post = $self->object->parent;
	$self->model->payload->urify($blog_post);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
