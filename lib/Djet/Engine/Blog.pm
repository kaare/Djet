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
	$self->add_options(order_by => {'-desc' => "datacolumns->>'publish_date'"});
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
