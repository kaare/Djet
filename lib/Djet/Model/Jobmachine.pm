package Djet::Model::Jobmachine;

use 5.010;
use Moose;
use YAML;

use Job::Machine::DB;

with qw/
	Djet::Part::Basic
	Djet::Part::Generic::Urify
/;

=head1 DESCRIPTION

Djet::Model::Jobmachine interfaces to the Job::Nachine classes, taskes, and results through Job::Machine::DB.

=head1 ATTRIBUTES

=head2 stats

Translate stat_id to text

=cut

has 'stats' => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my %stats = (
			0 => 'Entered',
			100 => 'Processing',
			200 => 'Finished',
			900 => 'Error',
		);
		return \%stats;
	},
	lazy => 1,
);

=head2 jobdb

The Jobmachine database object

=cut

has 'jobdb' => (
	is => 'ro',
	isa => 'Job::Machine::DB',
	default => sub {
		my $self = shift;
		my $model = $self->model;
		my $dbh = $model->storage->dbh;
		my $db = Job::Machine::DB->new(
			dbh => $dbh,
		);
		return $db;
	},
	lazy => 1,
);

=head2 params

The Post parameters

=cut

has 'params' => (
	is => 'ro',
	isa => 'Hash::MultiValue',
	default => sub {
		my $self = shift;
		my $model = $self->model;
		my $params = $model->request->body_parameters;
		return $params;
	},
	lazy => 1,
);

=head2 basenode

The basenode, either from model->basenode, or found through the basetype.

It is expected there is exactly _one_ node with basetype 'jobmachine' in the system

=cut

has 'basenode' => (
	is => 'ro',
	isa => 'Djet::Schema::Result::Djet::DataNode',
	default => sub {
		my $self = shift;
		my $model = $self->model;

		my $basetype = $model->basetype_by_name('jobmachine') or return;
		return $self->model->basenode if $self->model->basenode->basetype_id == $basetype->id;

		return $model->resultset('Djet::DataNode')->find({basetype_id => $basetype->id});
	},
	lazy => 1,
);

=head2 task_path

The path, from the basetype path, where the tasks are found

=cut

has 'task_path' => (
	is => 'ro',
	isa => 'Str',
	default => 'task',
	lazy => 1,
);

=head2 task_id

Id of the task

=cut

has 'task_id' => (
	is => 'ro',
	isa => 'Int',
);

=head2 job_uri

The uri of the job. The task_id might be the optional parameter.

=cut

has 'job_uri' => (
	is => 'ro',
	isa => 'Djet::Schema::Result::Djet::DataNode',
	default => sub {
		my $self = shift;
		my $model = $self->model;
		my $base_path = $self->basenode->node_path;

		my @elements = ($base_path, $self->task_path, $self->task_id);
		return $self->urify(join '/', @elements);
	},
	lazy => 1,
);

=head1 METHODS

=head2 list_statuses

List the statuses to choose from

=cut

sub list_statuses {
	my $self = shift;
	my $db = $self->jobdb;
	my $stats = $self->stats;

	my @statuses = ({id => 'all', => title => 'All'}, map {{id => $_->{status}, title => $stats->{$_->{status}}}} @{ $db->get_statuses } );
	my $id = $self->params->{status};
	return {
		id => $id,
		default => \@statuses,
	};
}

=head2 list_classes

List the classes to choose from

=cut

sub list_classes {
	my $self = shift;
	my $model = $self->model;

	my $db = $self->jobdb;
	my @classes = ({id => 'all', => title => 'All'}, map {{id => $_->{class_id}, title => $_->{name}}} @{ $db->get_classes } );
	my $id = $self->params->{class};
	return {
		id => $id,
		default => \@classes,
	};
}

=head2 list_tasks

List the tasks to choose from

=cut

sub list_tasks {
	my $self = shift;
	my $model = $self->model;
	my $db = $self->jobdb;
	my $stats = $self->stats;
	my $base_path = $self->basenode->node_path;

	my %where = map {$_ => $self->params->{$_}} qw/status class/;
	my $tasks = $db->get_tasks;
	my @headers = qw/task_id name title status created run_after/;
	my $task_list = {
		header => \@headers, 
		link => 1,
		rows => [ map {
			my $row = $_;
			[ map {
				my $field = $_;
				my %parms = (name => $field, value => $row->{$field}, updatable => 0);
				$parms{value} = $stats->{$parms{value}} if $field eq 'status';
				$parms{link} = $self->urify(join '/', $base_path, $self->task_path, $row->{$field}) if $field eq 'task_id';
				Djet::Field->new(%parms)
			} @headers ]
		} @$tasks ],
	};
	return $task_list;
}

=head2 one_task

Return task and results for one job

=cut

sub one_task {
	my $self = shift;
	my $model = $self->model;
	my $db = $self->jobdb;
	my $stats = $self->stats;
	my $task = $db->fetch_task($self->task_id) or return;
	my $results = $db->fetch_results($self->task_id);

	my @fields = qw/name status parameters run_after created modified/;
	my $task_flds = [ map {
		my $field = $_;
		my $type = $field eq 'parameters' ? 'Structured' : 'Str';
		my %parms = (name => $field, title => ucfirst $field, value => $task->{$field}, updatable => 0, type => $type);
		$parms{value} = $stats->{$parms{value}} if $field eq 'status';
		my $fieldtraitname = "Djet::Trait::Field::$type";
		eval "require $fieldtraitname";
		$@ ? 
			Djet::Field->new(%parms) :
			Djet::Field->with_traits($fieldtraitname)->new(%parms);
	} @fields ];

	my @headers = qw/Result/;
	my $result_list = {
		header => \@headers, 
		rows => [ map {
			my $row = $_;
			[ map {
				my $field = $_;
				my %parms = (name => $field, value => $row, updatable => 0);
				Djet::Field->new(%parms)
			} @headers ]
		} @$results ],
	};
	return ($task_flds, $result_list);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
