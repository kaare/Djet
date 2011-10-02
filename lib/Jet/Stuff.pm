package Jet::Stuff;

use 5.010;
use Moose;
use MooseX::UndefTolerant;
use DBI;
use DBIx::TransactionManager 1.06;
use JSON;

use Jet::Stuff::Loader;
use Jet::Stuff::Result;
use Jet::Stuff::QueryBuilder;
# use Jet::Stuff::Schema;

with 'Jet::Role::Log';

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
has 'txn_manager' => (
	isa => 'DBIx::TransactionManager',
	is => 'ro',
	default => sub {
		my $self = shift;
		DBIx::TransactionManager->new($self->dbh);
	},
	lazy => 1,
);
has 'schema'       => (
	isa => 'DBIx::Inspector::Driver::Pg',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $dbh = $self->dbh;
		my $loader = Jet::Stuff::Loader->new(dbh => $dbh);
		return $loader->schema;
	}
);
has 'sql_builder' => (
	isa => 'Jet::Stuff::QueryBuilder',
	is => 'ro',
	default => sub {
		Jet::Stuff::QueryBuilder->new();
	},
	lazy => 1,
);
has 'json' => (
	isa => 'JSON',
	is => 'ro',
	default => sub {
		JSON->new();
	},
	lazy => 1,
);

sub disconnect {
	my $self = shift;
	delete $self->{txn_manager};
	if ( my $dbh = delete $self->{dbh} ) {
		$dbh->disconnect;
	}
}

sub update_basetype {
	my ($self, $where, $args) = @_;
	my $sql = 'UPDATE jet.basetype SET ' .
		join(',', map { "$_ = ?"} keys(%$args)) .
		' WHERE ' .
		join(',', map { "$_ = ?"} keys(%$where));
	$args->{recipe} = $self->json->encode($args->{recipe}) if $args->{recipe};
	my $sth = $self->_execute($sql, [ values %$args, values %$where ]) || return;
}

sub get_basetypes {
	my ($self, $where, $opt) = @_;
	my ($sql, @binds) = $self->sql_builder->select(
		"jet.basetype",
		'*',
		$where,
		$opt
	);
	my $sth = $self->_execute($sql, \@binds);
	my $basetypes = $sth->fetchall_arrayref({});
	return { map {$_->{recipe} = $self->json->decode($_->{recipe}) if $_->{recipe};{$_->{name} => $_} } @$basetypes };
}

sub find_basetype {
	my ($self, $args) = @_;
	my $sql = 'SELECT * FROM jet.basetype WHERE ' . join ',', map { "$_ = ?"} keys %$args;
	my $basetype = $self->single(sql => $sql, data => [ values %$args ]) || return;
	$basetype->{recipe} = $self->json->decode($basetype->{recipe}) if $basetype->{recipe};
	return $basetype;
}

sub find_node {
	my ($self, $args) = @_;
	my $sql = 'SELECT * FROM jet.nodepath WHERE ' . join ',', map { "$_ = ?"} keys %$args;
	my $node = $self->single(sql => $sql, data => [ values %$args ]) || return;

	$sql = "SELECT * FROM data.$node->{base_type} WHERE id=?";
	my $data = $self->single(sql => $sql, data => [ $node->{node_id} ]) || return;

	return Jet::Stuff::Row->new(row_data => { %$node, %$data }, table_name => $node->{base_type});
}

sub search {
	my ($self, $table_name, $where, $opt) = @_;
	my $table = $self->schema->table( $table_name );
	if (! $table) {
		Carp::croak("No such table $table_name");
	}

	my @column_names = (qw /title node_path parent_id/, map { $_->name } $table->columns ); # XXX view columns should be configurable
	my ($sql, @binds) = $self->sql_builder->select(
		"data.$table_name\_view",
		\@column_names,
		$where,
		$opt
	);
	$self->search_by_sql($sql, \@binds, $table_name);
	my $sth = $self->_execute($sql, \@binds);
	return $sth->fetchall_arrayref({}),
}

sub search_nodepath {
	my ($self, $base_type, $where, $opt) = @_;
	my ($sql, @binds) = $self->sql_builder->select(
		"jet.nodepath",
		'*',
		$where,
		$opt
	);
	my $sth = $self->_execute($sql, \@binds);
	return $sth->fetchall_arrayref({}),
}

sub insert {
	my ($self, $table_name, $data, $opt) = @_;
	my ($sql, @binds) = $self->sql_builder->insert(
		"data.$table_name\_view",
		$data,
		$opt
	);
	return $self->single(sql => $sql, data => \@binds);
}

sub move {
	my ($self, $node_id, $parent_id) = @_;
	my $sql = qq{UPDATE
		jet.path
	SET
		parent_id=?
	WHERE
		node_id=?
	};
	return  $self->_execute($sql, [$parent_id, $node_id]);
}

sub search_by_sql {
	my ($self, $sql, $bind, $table_name) = @_;
	$table_name ||= $self->_guess_table_name( $sql ); # XXX
	my $sth = $self->_execute($sql, $bind);

	my $result = Jet::Stuff::Result->new(
#		Stuff           => $self,
		rows             => $sth->fetchall_arrayref({}),
		sql                => $sql,
		table_name  => $table_name,
	);
	$sth->finish;
	return wantarray ? $result->all : $result;
}

sub _execute { # XXX Redo. Not pretty
	my ($self, $sql, $bind) = @_;
	my $sth = $self->dbh->prepare($sql);
	$sth->execute(@{$bind || []});
	return $sth;
}

sub row {
	my ($self, $data, $table_name) = @_;
	return Jet::Stuff::Row->new(row_data => $data, table_name => $table_name);
}

sub result {
	my ($self, $data) = @_;
	return Jet::Stuff::Result->new(rows => $data);
}

sub single {
	my ($self, %args) = @_;
	my $sth = $self->_execute($args{sql}, $args{data});
	my $r = $sth->fetchrow_hashref();
	$sth->finish();
	return $r;
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

#
# Notify methods
#

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

# sub DESTROY {
	# $_[0]->disconnect();
	# return;
# }

#
# for transaction
#

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

__PACKAGE__->meta->make_immutable;

1;