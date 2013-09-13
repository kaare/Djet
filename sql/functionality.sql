--
-- Jet functionality
--
-- Full Text Search (fts)


SET search_path TO jet, public;

-- fts

CREATE OR REPLACE FUNCTION update_fts() RETURNS trigger AS $$
	# jet.basetype
	my $q = "SELECT * FROM jet.basetype WHERE id = $_TD->{new}{basetype_id}";
	my $rv = spi_exec_query($q);
	unless ($rv->{status} eq 'SPI_OK_SELECT' and $rv->{processed} == 1) {
		elog(ERROR,"Basetype $base_name not found in jet.basetype");
		return SKIP;
	}

	my $base_row = $rv->{rows}->[0];
	my $base_columns = $base_row->{datacolumns};
	my $searchable = $base_row->{searchable};
	return MODIFY unless @{ $base_columns } and @{ $searchable };

	my @datacols = @{ $_TD->{new}{datacolumns} };
	my ($columns, $fts);
	$columns->{$_} = shift @datacols for @{ $base_columns };
	$fts = join ' ', map {$columns->{$_}} grep {$columns->{$_}} @$searchable; # Find searchable columns with content
	$_TD->{new}{fts} = $fts;
	return MODIFY;
$$
LANGUAGE 'plperl' VOLATILE;

CREATE TRIGGER update_fts BEFORE INSERT OR UPDATE ON data FOR EACH ROW EXECUTE PROCEDURE jet.update_fts();
