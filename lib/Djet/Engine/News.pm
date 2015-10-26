package Djet::Engine::News;

use 5.010;
use Moose;

extends 'Djet::Engine::Children';

=head1 NAME

Djet::Engine::News

=head2 DESCRIPTION

News items are grouped under a News node. Displayed sorted descending on date with
a configurable limit. Older news items are archived under their separate years. 

=head1 METHODS

=head2 before init_data

Set the list name to 'news_feed'

=cut

before 'init_data' => sub  {
	my $self = shift;
	$self->set_list_name('news_feed');
	$self->add_options('order_by', {'-desc' => 'node_modified'});
};

=head2 after data

Set the list name to 'news_feed'

=cut

after 'data' => sub  {
	my $self = shift;
	my $model = $self->model;
	my $stash = $model->stash;
	if (my $year = $model->request->param('year')) {
		$self->add_search(data_created => { '-between' => [ $year . '-01-01', $year . '-12-31' ] });
	}
	my $archive = $stash->{news_feed};
	$stash->{news_archive} = $archive->search(undef, {
		select => [ \"date_part('year', data_created)", \"count(*)" ],
		as => [qw/year count/],
		group_by => 1,
		order_by => { '-desc' => 1},
	});
};


__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
