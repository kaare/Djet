package Djet::Part::Job::Worker;

use 5.010;
use Moose::Role;
use namespace::autoclean;

use Time::HiRes qw/gettimeofday tv_interval/;

=head1 NAME

Djet::Part::Job::Worker

=head1 DESCRIPTION

Paint a little around Job::Machine::Worker process

=head1 ATTRIBUTES

=head2 _start_time

The time when the process started

=cut

has '_start_time' => (
	is => 'rw',
	isa => 'ArrayRef',
);

=head1 METHODS

=head2 before process

Gets the time

=cut

before 'process' => sub {
	my ($self, $task) = @_;
	my $t0 = [gettimeofday];
	$self->_start_time($t0);
	warn "Processing task $task->{task_id}";
};


=head2 after process

Displays the time used

=cut

after 'process' => sub {
	my ($self, $task) = @_;
	my $elapsed = tv_interval ( $self->_start_time );
	warn "Finished job in $elapsed seconds";
};

no Moose::Role;

1;

#COPYRIGHT
