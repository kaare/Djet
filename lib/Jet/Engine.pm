package Jet::Engine;

use 5.010;
use Moose;

with qw/Jet::Role::Log/;

=head1 NAME

Jet::Engine - Jet Engine Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engines.

In your engine you just write

extends 'Jet::Engine';

=head1 ATTRIBUTES

=cut

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
has basenode => (
	isa => 'Jet::Basenode',
	is => 'ro',
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
);
has all_components => (
	isa     => 'ArrayRef[HashRef]',
	is => 'ro',
	default => sub {
		my $self = shift;
		return $self->basenode->basetype->recipe->components;
	},
	lazy => 1,
);
has run_components => (
	traits  => ['Array'],
	isa     => 'ArrayRef[HashRef]',
	is => 'rw',
	handles => {
		all_runcomponents    => 'elements',
		add_runcomponent     => 'push',
		map_runcomponents    => 'map',
		filter_runcomponents => 'grep',
		find_runcomponent    => 'first',
		get_runcomponent     => 'get',
		join_runcomponents   => 'join',
		count_runcomponents  => 'count',
		has_runcomponents    => 'count',
		has_no_runcomponents => 'is_empty',
		sorted_runcomponents => 'sort',
	},
);

=head2 arguments

This is the set of arguments for this engine

=cut

has 'arguments' => (
	isa => 'HashRef',
	is => 'ro',
);

=head1 METHODS

=head2 conditions

The engine's conditions

=cut

sub conditions {
	my $self = shift;
	my @components = @{ $self->all_components };
	my $arguments = $self->arguments;
	$self->_handle_condition($_, $arguments) for @components;
}

sub _handle_condition {
	my ($self, $component, $arguments) = @_;
	my $component_fullname = $component->{fullname};
	# Determine if this condition is met. Return if not
	for my $condition (@{ $component->{conditions} }) {
		my $conditionname = $condition->{name} || $condition->{part};
		my $fullname = join '_', $component_fullname, $conditionname;
		my $class = $arguments->{$fullname}{class};
		my $args  = $self->_handle_arguments($arguments->{$fullname}{args});
		my $cond_obj = $class->new(engine => $self, %$args);
		warn "testing $component_fullname condition $class " . $cond_obj->condition;
		return unless $cond_obj->condition;
	}

	# Condition is true. Add component to the ones to run
	$self->add_runcomponent($component);
	$self->response->template($component->{template}) if $component->{template};
}

=head2 parts

The engine parts

=cut

sub parts {
	my $self = shift;
	my @components = @{ $self->all_components };
	my $arguments = $self->arguments;
	my @steps;
	for my $component ($self->all_runcomponents) {
		my $component_fullname = $component->{fullname};
		for my $step (@{ $component->{steps} }) {
			my $partname = $step->{name} || $step->{part};
			my $fullname = join '_', $component_fullname, $partname;
			my $class = $arguments->{$fullname}{class};
			my $args  = $self->_handle_arguments($arguments->{$fullname}{args});
			warn "setting up $component_fullname as $class";
			push @steps, $class->new(engine => $self, %$args);
		}
	}
	warn 'processing ' . join ', ', map {ref $_} @steps;
	warn 'init';
	$_->init for @steps;
	warn 'run';
	$_->run for @steps;
	warn 'render';
	$_->render for @steps;
}

sub _handle_arguments {
	my ($self, $parms) = @_;
	my $stash = $self->stash;
	my $parameters = $self->request->parameters;
	my $args = $self->basenode->arguments;
	while (my ($name, $parm) = each %$parms) {
		if (ref $parm eq 'HASH') {
			$parms->{$name} = $self->_replace_argument($parm, $stash, $parameters, $args);
		}
	}
	return $parms;
}

sub _replace_argument {
	my ($self, $parms, $stash, $parameters, $args) = @_;
	my $result;
	while (my ($name, $parm) = each %$parms) {
		$result->{$name} = $self->_replace_argument($parm) if (ref $parm eq 'HASH');
		given (lc $name) {
			when ('stash') {
				$result->{$name} = $stash->{$name};
			}
			when ('param') {
				$result->{$name} = $parameters->{$name};
			}
			when ('arg') {
				$result = $args->[$parm - 1];
			}
			default {$result = $parm}
		}
	}
	return $result;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

