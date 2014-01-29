package Jet::Engine::Basetype;

use 5.010;
use Moose;

extends 'Jet::Engine';
with qw/Jet::Role::Update Jet::Role::Log/;

=head1 DESCRIPTION

Jet::Engine::Basetype configures Jet basetypes.

=head1 ATTRIBUTES

=head2 parts

This is the engine parts

=cut

has _parts => (
	traits	=> [qw/Jet::Trait::Engine/],
	is		=> 'ro',
	isa		=> 'ArrayRef',
	parts => [
	],
);

=head1 METHODS

=head2 data

Basically, just edit functionality

=cut

before data => sub {
	my $self = shift;
	$self->edit;
};

=head2 edit_view

Find stash content and template for viewing basetype config

=cut

after edit_view => sub {
	my $self = shift;
	my $nodes = $self->response->data_nodes;
	my $rest_path = $nodes->rest_path;
	my @basetypes = $self->schema->resultset('Basetype')->search(undef, {order_by => 'id'});
	$self->stash->{basetypes} = [ @basetypes ];
	($self->stash->{current_basetype}) = grep {$rest_path eq $_->name} @basetypes;
	$self->stash->{request} = $self->request;

	# Return
	my $response = $self->response;
	$response->template('config/basetype.tx');
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
