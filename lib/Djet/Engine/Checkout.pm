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
		my $model = $self->model;
		my @steps = $model->resultset('Djet::DataNode')->search({
			parent_id => $model->basenode->node_id,
		},{
			order_by => 'node_path',
		});
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
		my $model = $self->model;
		my $session = $model->session;
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
	my $model = $self->model;
	my $next_step = $model->rest_path || 1;
	$next_step = 1 unless $next_step =~ /^\d+$/;
	my $steps = $self->steps;
	for my $step (1 .. $next_step) {
		unless ($checkout->{ok}[$step-1]) {
			$next_step = $step;
			last;
		}
	}
	$model->session->{checkout}{next_step} = $next_step;
	my $current_step = $steps->[$next_step - 1];

	$model->stash->{steps} = $steps;
	$model->stash->{current_step} = $current_step;
	my $step_name = $current_step->name;

    # Give the step the possibility to do sth first
    my $step_object = $self->_make_step($current_step);
    $step_object->data;

	$model->stash->{defaults} = $checkout->{data}{$step_name} if exists $checkout->{data}{$step_name};
	$model->stash->{checkout_data} = $checkout->{data} if exists $checkout->{data};
    $model->stash->{checkout_step} = $next_step;

	my $template = $current_step->basetype->template;

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
	$step = @$steps - 1 if $step > @$steps;
	my $current_step = $steps->[$step-1];
    warn "Step " . $current_step->name;
    my $step_object = $self->_make_step($current_step);
	return unless my $step_ok = $step_object->has_all_data;

	$checkout->{ok}[$step-1] = $step_ok;
	$checkout->{next_step} = $step + 1 unless $checkout->{next_step} >= @$steps;
	$self->model->session->{checkout} = $checkout;
	return 1;
}


sub _make_step {
    my ($self, $step) = @_;
	my $handler = $step->basetype->handler;
	eval "require $handler" or die "No handler $handler: $@";

	return $handler->new(
		model => $self->model,
		mailer => $self->mailer,
		checkout => $self->checkout,
		step => $step,
	);
}

=head2 process_post

Process the edit POST

=cut

sub process_post {
	my ($self) = @_;
	$self->stash_basic;
	my $model = $self->model;
	my $request = $model->request;
	$self->_stash_defaults;
	$self->response->body($self->view_page);
}

sub _stash_defaults {
	my ($self) = @_;
	my $model = $self->model;
	my $request = $model->request;
	$model->stash->{defaults} = $request->parameters->as_hashref;
	while (my ($fieldname, $upload) = each %{ $request->uploads }) {
		$model->stash->{defaults}{$fieldname} = $upload->filename;
	}
}

=head2 create_path

Process the POST request for creating a node

=cut

sub create_path {
	my $self = shift;
	my $model = $self->model;
	my $step = $model->session->{checkout}{next_step};
	my $url = $model->payload->urify;
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
