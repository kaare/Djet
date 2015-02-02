package Djet::Engine::Checkout;

use 5.010;
use Moose;
use JSON;

extends 'Djet::Engine::Default';

use Djet::Shop::Cart;

=head1 NAME

Djet::Engine::Checkout

=head2 DESCRIPTION

Handles the checkout process

=head1 ATTRIBUTES

=head2 cart

The cart object

=cut

has cart => (
	is => 'ro',
	isa => 'Djet::Shop::Cart',
	default => sub {
		my $self = shift;
		my $cart = Djet::Shop::Cart->new(
			model => $self->model,
			uid => 1,
		);
	},
	lazy => 1,
);

=head2 steps

The checkout steps as fetched from the database and ordered by node_modified

=cut

has 'steps' => (
	is => 'ro',
	isa => 'ArrayRef',
	default => sub {
		my $self = shift;
		my @steps = $self->model->resultset('Djet::DataNode')->search({
			parent_id => $self->basenode->node_id,
		},{
			order_by => 'node_modified',
		});
		push @steps, {title => $self->basenode->basetype->attributes->{step_name}};
		return \@steps;
	},
	lazy => 1,
);

=head2 checkout

The current checkout data

=cut

has checkout => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {
		my $self = shift;
		my $session = $self->session;
		return { next_step => 1 } unless defined $session && $session->{checkout};

		return $session->{checkout};
	},
	lazy => 1,
);

=head1 METHODS

=head2 after BUILD

Add the form content type

=cut

after BUILD => sub {
	my $self = shift;
	$self->add_accepted_content_type( { 'application/x-www-form-urlencoded' => 'create_by_post' });
};

=head2 allowed_methods

Allow POST for updating (Web::Machine)

=cut

sub allowed_methods {
	return [qw/GET HEAD POST/];
}

=head2 before data

Checks all steps up to the wanted step to see if data are entered correctly.

=cut

before 'data' => sub {
	my $self = shift;
	my $checkout = $self->checkout;
	my $next_step = $self->rest_path || 1;
	$next_step = 1 unless $next_step =~ /^\d+$/;
	my $steps = $self->steps;
	for my $step (1 .. $next_step) {
		unless ($checkout->{ok}[$step-1]) {
			$next_step = $step;
			last;
		}
	}
	$self->session->{checkout}{next_step} = $next_step;
	my $current_step = $next_step == @$steps ? $self->basenode : $steps->[$next_step - 1];

	$self->stash->{steps} = $steps;
	$self->stash->{current_step} = $current_step;
	my $step_name = $current_step->name;
	$self->stash->{defaults} = $checkout->{data}{$step_name} if $checkout->{data}{$step_name};

	my $template //= $current_step->basetype->template;
	$template = $self->template_substitute($template) if defined($template) and $template =~ /<.+>/;
	$self->template($template);
};


=head2 post_is_create

Checks all steps up to the wanted step to see if data are entered correctly.

  Continue with create_path if the validation went well
  Continue with process_post if there was something wrong in the validation

=cut

sub post_is_create {
	my ($self) = @_;
	my $checkout = $self->checkout;
	my $step = $checkout->{next_step} // $self->rest_path || 1;
	my $steps = $self->steps;
	$step = @$steps - 1 if $step >= @$steps;
	my $current_step = $steps->[$step-1];
	my $handler = $current_step->basetype->handler;
	eval "require $handler" or die "No handler $handler";

	my $step_object = $handler->new(
		body => $self->body,
		model => $self->model,
		mailer => $self->mailer,
		checkout => $checkout,
		step => $current_step,
	);
	return unless my $step_ok = $step_object->has_all_data;

	$checkout->{ok}[$step-1] = $step_ok;
	$checkout->{next_step} = $step + 1 unless $checkout->{next_step} >= @$steps;
	$self->session->{checkout} = $checkout;
	return 1;
}

=head2 process_post

Process the edit POST

=cut

sub process_post {
	my ($self) = @_;
	$self->stash_basic;
	my $request = $self->body->request;
	$self->_stash_defaults;
	$self->response->body($self->view_page);
}

sub _stash_defaults {
	my ($self) = @_;
	my $request = $self->body->request;
	$self->stash->{defaults} = $request->parameters->as_hashref;
	while (my ($fieldname, $upload) = each %{ $request->uploads }) {
		$self->stash->{defaults}{$fieldname} = $upload->filename;
	}
}

=head2 create_path

Process the POST request for creating a node

=cut

sub create_path {
	my $self = shift;
	my $step = $self->session->{checkout}{next_step};
	my $url = $self->stash->{local}->urify;
	$url .= '/' unless $url =~ m|/$|;
	$url .= $step;
	return $url;
}

=head2 create_by_post

We go here if a x-www-form-urlencoded post wants to create a new node

=cut

sub create_by_post { return \302; }

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
