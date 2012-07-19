package Jet::Engine;

use 5.010;
use Moose;


with qw/Jet::Role::Log MooseX::Traits/;

=head1 NAME

Jet::Engine - Jet Engine Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engines.

In your engine you just write

extends 'Jet::Engine';

=head1 ATTRIBUTES

=head2 params

=head3 stash variables

Can be scalar, arrayref or hashref

=head4 arrayref

foo => [qw/bar baz/],

Results in a parameter value of

foo => {
	bar => <stash bar value>,
	baz => <stash baz value>,
}

=head3 content variables

=head4 hashref

foo => {
	bar => 'bar',
	baz => 'fooz',
},

Results in a parameter value of

foo => {
	bar => <content bar value>,
	baz => <content fooz value>,
}

=head2 parameters

=cut

has params => (
	isa => 'HashRef',
	is => 'ro',
);
has parameters => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $stash = $self->stash;
		my $content = $self->request->rest->parameters;
		my $vars;
		my $stash_params = $self->params->{stash};
		$vars->{$_} = $self->_parse_params($stash, $_, $stash_params->{$_}) for keys %$stash_params;
		my $content_params = $self->params->{content};
		$vars->{$_} = $self->_parse_params($content, $_, $content_params->{$_}) for keys %$content_params;
		my $static_params = $self->params->{static};
		$vars->{$_} = $static_params->{$_} for keys %$static_params;
		return $vars;
	},
	lazy => 1,
);
has config => (
	isa => 'Jet::Config',
	is => 'ro',
);
has schema => (
	isa => 'Jet::Stuff',
	is => 'rw',
);
has cache => (
	isa => 'Object',
	is => 'ro',
);
has basetypes => (
	isa       => 'HashRef',
	is        => 'ro',
);
has stash => (
	isa => 'HashRef',
	is => 'ro',
);
has request => (
	isa => 'Plack::Request',
	is => 'ro',
);
has node => (
	isa => 'Jet::Node',
	is => 'ro',
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
);
has run_components => (
	traits  => ['Array'],
	isa     => 'ArrayRef[Str]',
	is => 'rw',
	handles => {
		all_components    => 'elements',
		add_component     => 'push',
		map_components    => 'map',
		filter_components => 'grep',
		find_component    => 'first',
		get_component     => 'get',
		join_components   => 'join',
		count_components  => 'count',
		has_components    => 'count',
		has_no_components => 'is_empty',
		sorted_components => 'sort',
	},
);

sub _parse_params {
	my ($self, $container, $key, $params) = @_;
	given (ref $params) {
		when ('') {
			return $container->{$params};
		}
		when ('HASH') {
			my $var;
			$var->{$_} = $container->{$params->{$_}} for keys %$params;
			return $var;
		}
		when ('ARRAY') {
			my $var;
			$var->{$_} = $container->{$_} for @$params;
			return $var;
		}
	}
}

=head2 init

Initialization for this node

=cut

sub init {
}

=head2 run

Does the actual data processing and rendering for this node

=cut

sub run {
	my ($self) = @_;
	my $node = $self->node;
	my $recipe = $node->basetype->{recipe};
	# Check if the endpath was correct
	Jet::Exception->throw(NotFound => { message => $self->request->uri->as_string })
		if $node->endpath and !$recipe->{paths}{$node->endpath};

	my $steps = $node->endpath ?
		$recipe->{paths}{$node->endpath} :
		$recipe->{steps};
	for my $step (@$steps) {
		my $engine_name = "Jet::Engine::Part::$step->{part}";
		print STDERR "\n$engine_name: ";
		eval "require $engine_name" or next;
		print STDERR "found ";
		next if $step->{verb} and !($self->request->rest->verb ~~ $step->{verb});
		print STDERR "rest_allowed ";
		my $engine = $engine_name->new(
			params => $step,
		);
		$engine->can('setup') && $engine->setup;
		print STDERR "can ";
		# See if plugin can data and do it. Break out if there's nothing returned
		$engine->can('data') && last unless $engine->data;

		print STDERR "executed ";
	}
	my $template_name = $node->endpath ?
		$recipe->{html_templates}{$node->endpath} :
		$recipe->{html_template};
	$template_name ||= $node->get_column('node_path');
	$self->response->template($self->config->jet->{template_path} . $template_name . $self->config->jet->{template_suffix});
	return;
}

=head2 render

Render for this node

=cut

sub render {
}

__PACKAGE__->meta->make_immutable;

1;
__END__

