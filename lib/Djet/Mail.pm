package Djet::Mail;

use 5.010;
use Moose;
use namespace::autoclean;

use Email::Stuffer;

with 'Djet::Part::Basic';

=head1 NAME

Djet::Mail

=head1 DESCRIPTION

Sends email

=head1 ATTRIBUTES

=head2 renderer

=cut

has 'renderer' => (
	is => 'ro',
);

=head2 mailer

Email::Stuffer object

=cut

has 'mailer' => (
	is => 'ro',
	isa => 'Email::Stuffer',
	default => sub {
		my $self = shift;
		my $mailer = Email::Stuffer->new;
		my $transport = $self->config->config->{mail}{transport};
		if ($transport) {
			my ($moniker, $options) = @$transport;
			$mailer->transport($moniker, $options);
		}
		return $mailer;
	},
	lazy => 1,
);

=head1 METHODS

=head2 send

=cut

sub send {
	my ($self, %args) = @_;
	my $stash = $self->stash;
	my $mailbody = $self->renderer->render($args{template}, $stash);
	my @to = ref $args{to} && ref $args{to} eq 'ARRAY' ? @{ $args{to} } : ($args{to});
	$self->mailer->from($args{from})
		->to(@to)
		->subject($stash->{payload}->basenode->title)
		->html_body($mailbody)
		->send;
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

