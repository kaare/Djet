--
-- Djet functionality
--
-- Full Text Search (fts)

CREATE OR REPLACE LANGUAGE plperlu;

SET search_path TO djet, public;

-- fts

CREATE OR REPLACE FUNCTION djet.update_fts() RETURNS trigger AS $$
use 5.010;
use JSON;
use HTML::FormatText;
use subs qw/ERROR NOTICE/;

	# djet.basetype
	my $basetype_id = $_TD->{new}{basetype_id};
	my $q = "SELECT * FROM djet.basetype WHERE id = $basetype_id";
	my $rv = spi_exec_query($q);
	unless ($rv->{status} eq 'SPI_OK_SELECT' and $rv->{processed} == 1) {
		elog(ERROR,"Basetype $basetype_id not found in djet.basetype");
		return 'SKIP';
	}

	my $json = JSON->new;
	my $base_row = $rv->{rows}->[0];
	my $base_columns = $json->decode($base_row->{datacolumns}) // [];
	my $searchable = $base_row->{searchable} // [];
	return 'MODIFY' unless @$base_columns and @$searchable;

	# base_columns is the array version. basecols is the hash
	my $basecols = { map { (delete $_->{name} => $_) } @$base_columns };
	my $datacols = JSON->new->decode($_TD->{new}{datacolumns});

	# Find searchable columns with content and format according to style
	my $fts = join ' ', $_TD->{new}{title},
		map {
			my $fieldname = $_;
			my $value = $datacols->{$fieldname};
			if ($basecols->{$fieldname}{type} eq 'Html') {
				state $formatter = HTML::FormatText->new;
				$value = $formatter->format_from_string($value)
			}
			$value;
		} grep {$datacols->{$_}} @$searchable;
	$fts =~ s/[,-\/:]/ /g;

	$_TD->{new}{fts} = call('to_tsvector(text)', $fts);
	return 'MODIFY';
$$
LANGUAGE 'plperlu' VOLATILE;

DROP trigger IF EXISTS update_fts ON djet.data;
CREATE TRIGGER update_fts BEFORE INSERT OR UPDATE ON data FOR EACH ROW EXECUTE PROCEDURE djet.update_fts();
