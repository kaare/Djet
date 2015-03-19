package Djet::Part::Engine::Json;

use Moose::Role;
use namespace::autoclean;

# requires qw/init data return_value/;

=head1 NAME

Djet::Part::Engine::Json - Add functionality to json engines

=head1 METHODS

=head2 BUILD

Tell the machine that we want json

=cut

after BUILD => sub {
	my $self = shift;
	$self->add_provided_content_type( { 'application/json' => 'to_json' });
};

=head2 to_json

=cut

sub to_json {}

around to_json => sub {
	my $orig = shift;
	my $self = shift;
	$self->content_type('json');

	$self->init_data;
	return $self->return_value if $self->has_return_value;

	$self->$orig(@_);
	return $self->return_value if $self->has_return_value;

	$self->data;
	return $self->return_value if $self->has_return_value;

	return $self->renderer->render($self->model->stash);
};

no Moose::Role;

1;

# COPYRIGHT

__END__
