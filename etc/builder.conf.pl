{
	custom_column_info => sub {
	 	my ($table, $column_name, $column_info) = @_;
	 	if ($table eq 'data_node' && $column_name eq 'node_id') {
				$column_info->{is_nullable} = 0;
		 		return $column_info;
	 	}
	},
}

