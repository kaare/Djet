package Jet::Role::Engine::Html;

use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Engine::Html - Add functionality to html engines

requires qw/init data/;

=head1 METHODS

=head2 BUILD

Tell the machine that we want html

=cut

after BUILD => sub {
	my $self = shift;
	$self->add_content_type( { 'text/html' => 'to_html' });
};

=head2 to_html

=cut

sub to_html {}

around to_html => sub {
	my $orig = shift;
	my $self = shift;
	$self->content_type('html');

	$self->init_data;
	$self->$orig(@_);
	$self->data;

	$self->template($self->basenode->render_template) unless $self->_has_template;
	return $self->renderer->render($self->template, $self->stash);
};

no Moose::Role;

1;

# COPYRIGHT

__END__
