package Jet::Import::Nodes;

use 5.010;
use namespace::autoclean;
use Moose;
#use DateTime;
#use DateTime::Format::Pg;

with 'MooseX::Traits';

=head1 Description

Base class for handling the import of the spreadsheet file

=head1 Atttributes

=head2 schema

=cut

has 'schema' => (
	isa => 'Jet::Schema',
	is => 'ro'
);

=head2 dry_run

Set to true if this is only a test

=cut

has 'dry_run' => (
	isa => 'Bool',
	is => 'ro',
	default => 0
);

=head2 file_name

The name of the spreadsheet

=cut

has file_name => (
	is => 'ro',
	isa => 'Str',
);

=head1 "PRIVATE" ATTRIBUTES

=head2 import_iterator

An iterator for reading the import file

=cut

has 'import_iterator' => (
	is => 'ro',
	lazy_build => 1,
);

=head2 warnings

An arrayref w/ all the warnings picked up during processing

=cut

has 'warnings' => (
	traits  => ['Array'],
	is	  => 'ro',
	isa	 => 'ArrayRef[Str]',
	default => sub { [] },
	handles => {
		all_warnings	=> 'elements',
		add_warning	 => 'push',
		join_warnings   => 'join',
		count_warnings  => 'count',
		has_warnings	=> 'count',
		has_no_warnings => 'is_empty',
		clear_warnings  => 'clear',
	},
);

=head2 errors

An arrayref w/ all the errors picked up during processing

=cut

has 'errors' => (
	traits  => ['Array'],
	is	  => 'ro',
	isa	 => 'ArrayRef[Str]',
	default => sub { [] },
	handles => {
		all_errors	=> 'elements',
		add_error	 => 'push',
		join_errors   => 'join',
		count_errors  => 'count',
		has_errors	=> 'count',
		has_no_errors => 'is_empty',
		clear_errors  => 'clear',
	},
);

=head2 timestamp

Time of the import run.

=cut

has 'timestamp' => (
	isa => 'Str',
	is => 'rw',
	lazy => 1,
	default => sub {
		return DateTime::Format::Pg->format_datetime(DateTime->now);
	},
);

=head1 METHODS

=head2 _build_import_iterator

Build the import iterator. It can be either csv, xls or ods.

=cut

sub _build_import_iterator {
	my $self = shift;
	my $classname = 'Jet::Import::Iterator::Csv';
	eval "require $classname" or die $@;
	return $classname->new(file_name => $self->file_name);
}

=head2 validate

Validates the import file

=cut

sub validate {
	my ($self) = @_;
	my $iterator = $self->import_iterator;

	while (my $row = $iterator->next) {
		my $row_res = $self->handle_row($row, $iterator->lineno);
	}
}

=head2 handle_row

Handle each individual row.

=cut

sub handle_row {
	my ($self, $row, $lineno) = @_;

	# XXX validation
	# return $self->add_error("Some error at $lineno") if some condition;
	# return $self->add_warning("Some warning at $lineno") if some condition;

	# XXX processing
	# XXX caching

}

=head2 import_run

Imports the nodes after validate has been run

=cut

sub import_run {
	my ($self) = @_;
	die "Trying to run import even with errors!" if $self->has_errors;

	my $schema = $self->schema;
	my $transaction = sub {
		$self->import_transaction;
		# XXX $datanode_rs->populate(\@datanodes) if @datanodes;
		return;
	};
	my $rs;
	eval {
		$rs = $schema->txn_do($transaction);
	};
	if ($@) {
		$self->import_failed($@);
	} else {
		$self->import_succeeded;
	}
}

=head2 import_transaction

Called inside the transaction block

=cut

sub import_transaction { }


=head2 import_failed

Called if the import failed for some reason

=cut

sub import_failed {
	my ($self, $error) = @_;
	die "Database error: $error \n";
}

=head2 import_succeeded

Called after the import has finished succesful

=cut

sub import_succeeded { }

=head2 report

Make a report of what happened

=cut

sub report {
	my ($self) = @_;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT
