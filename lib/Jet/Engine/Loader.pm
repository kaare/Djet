package Jet::Engine::Loader;

use Moose;
use DBIx::Inspector;
use Carp ();

has 'dbh'       => (isa => 'DBI::db', is => 'ro');
#has 'namespace' => (isa => 'Str', is => 'ro');

sub load {
	my ($self) = @_;
	my $inspector = DBIx::Inspector->new(dbh => $self->dbh, schema => 'data');
	return { map {$_->name => $_} $inspector->tables };
	# for my $table_info ($inspector->tables) {
		# my $table_name = $table_info->name;
		# my @table_pk   = map { $_->name } $table_info->primary_key;
		# my @col_names;
		# my %sql_types;
		# for my $col ($table_info->columns) {
			# push @col_names, $col->name;
			# $sql_types{$col->name} = $col->data_type;
		# }

		# $schema->add_table(
			# Jet::Engine::Schema::Table->new(
				# columns      => \@col_names,
				# name         => $table_name,
				# primary_keys => \@table_pk,
				# sql_types    => \%sql_types,
				# inflators    => [],
				# deflators    => [],
				# row_class    => join '::', $namespace, 'Row', Jet::Engine::Schema::camelize($table_name),
			# )
		# );
	# }
}

1;