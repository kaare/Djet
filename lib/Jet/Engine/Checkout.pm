package Jet::Engine::Checkout;

use 5.010;
use Moose;
use JSON;

extends 'Jet::Engine::Default';

use Jet::Shop::Cart;

=head1 NAME

Jet::Engine::Checkout

=head2 DESCRIPTION

Handles the checkout process

=head1 ATTRIBUTES

=head2 cart

The cart object

=cut

has cart => (
	is => 'ro',
	isa => 'Jet::Shop::Cart',
	default => sub {
		my $self = shift;
		my $cart = Jet::Shop::Cart->new(
			schema => $self->schema,
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
		my @steps = $self->schema->resultset('Jet::DataNode')->search({
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
		my $session = $self->session->{session};
		return $session if defined $session;

		return { next_step => 1 };
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
	my $next_step = $self->rest_path // 1;
	my $steps = $self->steps;
	$self->stash->{steps} = $steps;
	my $current_step = $next_step == @$steps ? $self->basenode : $steps->[$next_step - 1];

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
	my $next_step = $self->rest_path // 1;
	my $steps = $self->steps;

	for my $step (1 .. $next_step) {
		my $current_step = $steps->[$step - 1];
		my $handler = $current_step->basetype->handler;
		eval "require $handler" or die "No handler $handler";

		my $step_object = $handler->new(
			body => $self->body,
			checkout => $self->checkout,
		);
		return unless $step_object->has_all_data;
	}
	$self->stash->{cart}{next_step} = $next_step + 1;
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

=head2 create_path

Process the POST request for creating a node

=cut

sub create_path {
	my $self = shift;
	my $step = $self->stash->{cart}{next_step};
	my $url = join '/', $self->basenode->urify($self->stash->{local}->domain_node), 
		$step;
	return $url;
}

=head2 create_by_post

We go here if a x-www-form-urlencoded post wants to create a new node

=cut

sub create_by_post { return \302; }

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
