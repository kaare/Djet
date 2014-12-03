package Jet::Role::Engine::Json;

use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Engine::Json - Add functionality to json engines

requires qw/init data omit_run/;

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

	$self->init;
	$self->$orig(@_);
	$self->data unless $self->omit_run->{all};
	return $self->renderer->render($self->stash);
};

no Moose::Role;

1;

# COPYRIGHT

__END__
