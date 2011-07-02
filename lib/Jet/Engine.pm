package Jet::Engine;

use 5.010;
use Moose;
use MooseX::UndefTolerant;
use DBI;
use DBIx::TransactionManager 1.06;

use Jet::Engine::Loader;
# use Jet::Engine::Row;
# use Jet::Engine::Iterator;
# use Jet::Engine::Schema;

=head1 Attributes

=cut

has 'dbname' => (isa => 'Str', is => 'ro');
has 'username' => (isa => 'Str', is => 'ro');
has 'password' => (isa => 'Str', is => 'ro');
has 'connect_options' => (isa => 'HashRef', is => 'ro');

has 'dbh' => (
	isa => 'DBI::db',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $dsn = 'dbi:Pg:dbname='.$self->dbname;
		DBI->connect($dsn, $self->username, $self->password, $self->connect_options) or die;
	},
	lazy => 1,
);
has 'data_tables' => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		$self->_loader->load;
	},
	lazy => 1,
);
has 'txn_manager' => (
	isa => 'DBIx::TransactionManager',
	is => 'ro',
	default => sub {
		my $self = shift;
		DBIx::TransactionManager->new($self->dbh);
	},
	lazy => 1,
);

# "Internal" attributes
has '_loader' => (
	isa => 'Jet::Engine::Loader',
	is => 'ro',
	default => sub {
		my $self = shift;
		Jet::Engine::Loader->new(dbh => $self->dbh) or die;
	},
	lazy => 1,
);

__PACKAGE__->meta->make_immutable;

sub schemas {qw/jet data/};
# forcefully connect
sub connect {
	my ($self, @args) = @_;

	$self->in_transaction_check;

	if (@args) {
		$self->connect_info( \@args );
	}
	my $connect_info = $self->connect_info;
	$connect_info->[3] = {
		# basic defaults
		AutoCommit => 1,
		PrintError => 0,
		RaiseError => 1,
		%{ $connect_info->[3] || {} },
	};

	$self->{dbh} = eval { DBI->connect(@$connect_info) }
		or Carp::croak("Connection error: " . ($@ || $DBI::errstr));
	delete $self->{txn_manager};

	if ( my $on_connect_do = $self->on_connect_do ) {
		if (not ref($on_connect_do)) {
			$self->do($on_connect_do);
		} elsif (ref($on_connect_do) eq 'CODE') {
			$on_connect_do->($self);
		} elsif (ref($on_connect_do) eq 'ARRAY') {
			$self->do($_) for @$on_connect_do;
		} else {
			Carp::croak('Invalid on_connect_do: '.ref($on_connect_do));
		}
	}

	$self->_prepare_from_dbh;
}

sub reconnect {
	my $self = shift;

	if ($self->in_transaction) {
		Carp::confess("Detected disconnected database during a transaction. Refusing to proceed");
	}

	$self->disconnect();
	$self->connect(@_);
}

sub disconnect {
	my $self = shift;
	delete $self->{txn_manager};
	if ( my $dbh = delete $self->{dbh} ) {
		$dbh->disconnect;
	}
}

sub find_node {
	my ($self, $args) = @_;
	my $sql = 'SELECT * FROM jet.nodepath WHERE ' . join ',', map { "$_ = ?"} keys %$args;
	return $self->single(sql => $sql, data => [ values %$args ]);
}

sub search_by_sql {
	my ($self, $sql, $bind, $table_name) = @_;
	$table_name ||= $self->_guess_table_name( $sql );
	my $sth = $self->_execute($sql, $bind);
	my $itr = Jet::Engine::Iterator->new(
		'Jet::Engine'             => $self,
		sth              => $sth,
		sql              => $sql,
		row_class        => $self->schema->get_row_class($table_name),
		table_name       => $table_name,
		suppress_object_creation => $self->suppress_row_objects,
	);
	return wantarray ? $itr->all : $itr;
}

sub single {
	my ($self, %args) = @_;
	my $sth = $self->dbh->prepare($args{sql}) || return 0;

	unless($sth->execute(@{$args{data}})) {
		my @c = caller;
		print STDERR "File: $c[1] line $c[2]\n";
		print STDERR $args{sql}."\n" if($args{sql});
		return 0;
	}
	my $r = $sth->fetchrow_hashref();
	$sth->finish();
	return ( $r );
}

sub select_all {
	my ($self, %args) = @_;
	my $sth = $self->dbh->prepare($args{sql}) || return 0;

	$self->set_bind_type($sth,$args{data} || []);
	unless($sth->execute(@{$args{data}})) {
		my @c = caller;
		print STDERR "File: $c[1] line $c[2]\n";
		print STDERR $args{sql}."\n" if($args{sql});
		return 0;
	}
	my @result;
	while( my $r = $sth->fetchrow_hashref) {
			push(@result,$r);
	}
	$sth->finish();
	return ( \@result );
}

sub set_bind_type {
	my ($self,$sth,$data) = @_;
	for my $i (0..scalar(@$data)-1) {
		next unless(ref($data->[$i]));

		$sth->bind_param($i+1, undef, $data->[$i]->[1]);
		$data->[$i] = $data->[$i]->[0];
	}
	return;
}

sub do {
	my ($self, %args) = @_;
	my $sth = $self->dbh->prepare($args{sql}) || return 0;

	$sth->execute(@{$args{data}});
	my $rows = $sth->rows;
	$sth->finish();
	return $rows;
}

sub insert {
	my ($self, %args) = @_;
	$args{sql} .= ' RETURNING *';
	return $self->single(%args);
}

sub update {
	my $self = shift;
	$self->do(@_);
	return;
}

sub listen {
	my ($self, %args) = @_;
	my $queue = $args{queue} || return undef;

	for my $q (ref $queue ? @$queue : ($queue)) {
		$self->{dbh}->do(qq{listen "$q";});
	}
}

sub unlisten {
	my ($self, %args) = @_;
	my $queue = $args{queue} || return undef;

	for my $q (ref $queue ? @$queue : ($queue)) {
		$self->{dbh}->do(qq{unlisten "$q";});
	}
}

sub notify {
	my ($self, %args) = @_;
	my $queue = $args{queue} || return undef;
	my $payload = $args{payload};
	my $sql = qq{SELECT pg_notify(?,?)};
	my $task = $self->select_first(
		sql => $sql,
		data => [ $queue, $payload],
	);
}

sub get_notification {
	my ($self,$timeout) = @_;
	my $dbh = $self->dbh;
	my $notifies = $dbh->func('pg_notifies');
	return $notifies;
}

sub set_listen {
	my ($self,$timeout) = @_;
	my $dbh = $self->dbh;
	my $notifies = $dbh->func('pg_notifies');
	if (!$notifies) {
		my $fd = $dbh->{pg_socket};
		vec(my $rfds='',$fd,1) = 1;
		my $n = select($rfds, undef, undef, $timeout);
		$notifies = $dbh->func('pg_notifies');
	}
	return $notifies || [0,0];
}

sub task_id {
	return $_[0]->{task_id} || confess "No task id";
}

sub DESTROY {
	$_[0]->disconnect();
	return;
}

#--------------------------------------------------------------------------------
# for transaction

sub in_transaction_check {
	my $self = shift;

	return unless $self->txn_manager;

	if ( my $info = $self->{txn_manager}->in_transaction ) {
		my $caller = $info->{caller};
		my $pid    = $info->{pid};
		Carp::confess("Detected transaction during a connect operation (last known transaction at $caller->[1] line $caller->[2], pid $pid). Refusing to proceed at");
	}
}

sub txn_scope {
    my @caller = caller();
    $_[0]->txn_manager->txn_scope(caller => \@caller);
}

sub txn_begin    { $_[0]->txn_manager->txn_begin    }
sub txn_rollback { $_[0]->txn_manager->txn_rollback }
sub txn_commit   { $_[0]->txn_manager->txn_commit   }
sub txn_end      { $_[0]->txn_manager->txn_end      }

1;