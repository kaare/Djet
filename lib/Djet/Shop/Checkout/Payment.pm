package Djet::Shop::Checkout::Payment;

use 5.010;
use Moose;

extends 'Djet::Shop::Checkout';

=head1 NAME

Djet::Shop::Checkout::Payment

=head2 DESCRIPTION

Handles the payment in the checkout process

=head2 has_all_data

Checks if there is a terms parameter and processes the order if so

=cut

sub has_all_data {
	my $self = shift;
	my $stash = $self->stash;
	my $params = $self->request->body_parameters;

	return unless $params->{terms}; # user has to accept the terms

	return $self->process_order;
}

=head2 process_order

Checks if there is a terms parameter and processes the order if so

=cut

sub process_order {
	my $self = shift;
	my $checkout = $self->checkout;
	my $cart = $self->stash->{local}->cart;
	my $transaction = sub {
		$self->create_order($checkout, $cart);
		$self->reset_data($checkout, $cart);
	};
	eval { $self->schema->txn_do($transaction) };
	my $error=$@;

	if ($error) {
		$self->config->log->debug($error);
		$self->stash->{message} = $error;
		return;
	}

	$self->send_mail;
	return 1;
}

=head2 create_order

Create the real order

=cut

sub create_order {
	my $self = shift;
	warn "create the order";
}

=head2 reset_data

Reset data, session checkout and cart

=cut

sub reset_data {
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
	my $base_fields = $self->basenode->fields;
	my $in_fields = $self->object->fields;
	my @to = $base_fields->recipient->value, $in_fields->email->value;
	$self->stash->{template_display} = 'view';
	$self->object->discard_changes;
	$self->stash->{contactform} = $self->object;
	$mailer->send(
		template => $base_fields->template->value,
		to => \@to,
		from => $base_fields->from->value,
	);
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
