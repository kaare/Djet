package Djet::Engine::Blog;

use 5.010;
use Moose;

use DateTime;

extends 'Djet::Engine::Children';

=head1 NAME

Djet::Engine::Blog

=head2 DESCRIPTION

Blog handling

=head1 METHODS

=head2 before init_data

Set the list name to 'blogs'

=cut

before 'init_data' => sub  {
	my $self = shift;
	$self->set_list_name('blogs');
	$self->add_search("datacolumns->>'status'" => [qw/published scheduled/]);
	$self->add_search("datacolumns->>'publish_date'" => {'<=' => DateTime->now->ymd});
};

=head2 after data

Set the list name to 'news_feed'


after 'data' => sub  {
	my $self = shift;
	my $stash = $self->stash;
	if (my $year = $self->request->param('year')) {
		$self->add_search(data_created => { '-between' => [ $year . '-01-01', $year . '-12-31' ] });
	}
	my $archive = $stash->{blogs};
use Data::Dumper 'Dumper';
$Data::Dumper::Maxdepth = 4;
warn Dumper [ $stash->{blogs} ];
	$stash->{blogs} = $archive->search(undef, {
		select => [ \"date_part('year', data_created)", \"count(*)" ],
		as => [qw/year count/],
		group_by => 1,
		order_by => { '-desc' => 1},
	});
warn Dumper [ $stash->{blogs}->all_ref ];
};

=cut

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
