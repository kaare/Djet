package Jet::Engine::Contactform;

use 5.010;
use Moose;
use Encode qw/encode/;

extends 'Jet::Engine::Default';

=head1 NAME

Jet::Engine::Contactform - Search Engine

=head1 METHODS

=head2 init

Find the nodes based on the search string

=cut

after 'init_data' => sub  {
	my $self = shift;
	my $schema = $self->schema;
	my $basetype = $schema->basetype_by_name('contactform') or die "No basetype: contactform";
	my $data = $basetype->fields->new( datacolumns => {} );
	my $contactform = $self->schema->resultset('Jet::DataNode')->new({basetype_id => $basetype->id, datacolumns => $data});
	$self->stash->{contactform} = $contactform;
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
