package Jet::Mail;

use 5.010;
use Moose;
use namespace::autoclean;

use Email::Stuffer;

with 'Jet::Role::Basic';

=head1 NAME

Jet::Mail

=head1 DESCRIPTION

Sends email

=head1 ATTRIBUTES

=head2 renderer

=cut

has 'renderer' => (
	is => 'ro',
#	isa => 'Jet::Render:Html',
);

=head2 template

=cut

has 'template' => (
	is => 'ro',
	isa => 'Str',
);

=head2 from

=cut

has 'from' => (
	is => 'ro',
	isa => 'Str',
);

=head2 to

=cut

has 'to' => (
	is => 'ro',
	isa => 'ArrayRef',
);

=head1 METHODS

=head2 send

=cut

sub send {
	my $self = shift;
	my $mailbody = $self->renderer->render($self->template, $self->stash);
	Email::Stuffer->from($self->from)
		->to($self->to->[0])
		->text_body($mailbody)
		->send;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

