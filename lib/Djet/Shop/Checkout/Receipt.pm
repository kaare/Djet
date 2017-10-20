package Djet::Shop::Checkout::Receipt;

use 5.010;
use Moose;

extends 'Djet::Shop::Checkout';

=head1 NAME

Djet::Shop::Checkout::Receipt

=head1 DESCRIPTION

Handles the receipt in the checkout process

=head1 METHODS

=head2 data

Send data

=cut

sub data {
    my $self = shift;
	$self->send_mail;
}

=head2 cleanup

Reset data, session checkout and cart

=cut

sub cleanup {
	my $self = shift;
	warn "reset session";
	warn "reset cart";
}

=head2 send_mail

Send the order email(s)

=cut

sub send_mail {
	my $self = shift;
	my $mailer = $self->mailer;
	my $model = $self->model;
	my $nodedata = $model->basenode->nodedata;
	my $checkout = $self->checkout;

	push my @to, split /\t*,\t*/, $nodedata->recipients->value;
	push @to,  $checkout->{data}{checkout_address}{email};
    my $subject = $nodedata->subject->value;

	$model->stash->{template_display} = 'view';
	$mailer->send(
		template => $nodedata->mail_template->value,
		to => \@to,
		from => $nodedata->sender->value,
        subject => $subject,
	);
}


__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
