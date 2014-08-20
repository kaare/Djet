package Jet::Engine::Contactform;

use 5.010;
use Moose;
use Encode qw/encode/;

extends 'Jet::Engine::Default';
with qw/Jet::Role::Log Jet::Role::Update::Node/;

=head1 NAME

Jet::Engine::Contactform - Search Engine

=head1 METHODS

=head2 init_data


=cut

after 'init_data' => sub  {
	my $self = shift;
	my $schema = $self->schema;
	my $basetype = $schema->basetype_by_name('contactform') or die "No basetype: contactform";
	my $data = $basetype->fields->new( datacolumns => {} );
	my $contactform = $self->schema->resultset('Jet::DataNode')->new({basetype_id => $basetype->id, datacolumns => $data});
	$self->stash->{contactform} = $contactform;
};

=head2 process_post


=cut

before 'process_post' => sub  {
	my $self = shift;
	my $schema = $self->schema;
	my $basetype = $schema->basetype_by_name('contactform') or die "No basetype: contactform";
	my $data = $basetype->fields->new( datacolumns => {} );
	my $contactform = $self->schema->resultset('Jet::DataNode')->new({basetype_id => $basetype->id, datacolumns => $data});
	$self->set_object($contactform);
	$self->stash->{contactform} = $contactform;
	$self->is_new(1);
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
