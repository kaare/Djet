package Djet::Engine::Admin::Jobmachine;

use 5.010;
use Moose;

use Djet::Model::Jobmachine;

extends 'Djet::Engine::Default';
# with qw/
# /;

=head1 DESCRIPTION

Djet::Engine::Admin::Jobmachine interfaces to the Job::Nachine classes, taskes, and results through Job::Machine::DB.

=head1 ATTRIBUTES

=head2 jm

The Jobmachine object.

If there is a rest_path with a task_id, this is also initialized

=cut

has 'jm' => (
	is => 'ro',
	isa => 'Djet::Model::Jobmachine',
	default => sub {
		my $self = shift;

		my %params = (
			model => $self->model,
		);
		if (my @path = split '/', $self->model->rest_path) {
			if ($path[0] eq 'task' and my $task_id = $path[1]) {
				$params{task_id} = $task_id;
			}
		}
		my $jm = Djet::Model::Jobmachine->new(%params);
		return $jm;
	},
	lazy => 1,
);

=head1 METHODS

=head2 allowed_methods

Allow POST for updating (Web::Machine)

=cut

sub allowed_methods {
	return [qw/GET POST/];
}

=head2 post_is_create

Make sure to run process_post by returning 0

=cut

sub post_is_create { return 0 }

=head2 data


=cut

before data => sub {
	my $self = shift;
	my $model = $self->model;

	# Dispatch to show_result or show_task
	my @path = split '/', $self->model->rest_path;
	return $self->show_result($path[3]) if $path[2] eq 'result' and $path[3];
	return $self->show_task if $self->model->rest_path;

	my $jm = $self->jm;
	my $stash = $model->stash;

	$stash->{title} = 'Jobs';
	$stash->{stats} = $jm->list_statuses;
	$stash->{classes} = $jm->list_classes;
	$stash->{tasks} = $jm->list_tasks;
};

=head2 process_post

Process the POST.

=cut

sub process_post {
	my $self = shift;
	my $model = $self->model;
	$self->response->body($self->view_page);
}

=head2 show_task

Display one task

=cut

sub show_task {
	my $self = shift;
	my $model = $self->model;
	my $stash = $model->stash;

	my ($task, $results) = $self->jm->one_task;
	$stash->{task} = $task;
	$stash->{results} = $results;
}

=head2 show_result

Display one result

=cut

sub show_result {
	my ($self, $result_id) = @_;
	my $model = $self->model;
	my $stash = $model->stash;

	my ($result, $type, $headers) = $self->jm->one_result($result_id) or return;

	if ($type) {
		$self->content_type($type);
		while (my ($key, $value) = each %$headers) {$self->response->header($key, $value)};
		$self->response->body($result);
		$self->return_value(\200);
	} else {
		$stash->{result} = $result;
	}
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
