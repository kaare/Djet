package Djet::Part::Job::Client;

use 5.010;
use Moose::Role;
use namespace::autoclean;
use Job::Machine::Client;

=head1 NAME

Djet::Part::Job::Client

=head1 DESCRIPTION

Contains a Job::Machine::Client object

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 queue

The queue. Default is the queue name from the basenode

=cut

has 'jobqueue' => (
	is => 'ro',
	isa => 'Str',
	default => sub {
		my $self = shift;
		my $model = $self->model;
		return $model->basenode->queue->value;
	},
	lazy => 1,
);

=head2 jobclient

The Job::Machine::Client object.

There has to be a queue name, either provided upon instantiation, or from the basenode.

=cut

has 'jobclient' => (
	is => 'ro',
	isa => 'Job::Machine::Client',
	default => sub {
		my $self = shift;
		my $model = $self->model;
		my $dbh = $model->storage->dbh;
		my $queue = $self->jobqueue;

		return Job::Machine::Client->new(
			dbh => $dbh,
			queue => $queue,
		) if defined($queue);
	},
	lazy => 1,
);

no Moose::Role;

1;

#COPYRIGHT
