package Jet::Engine::Basetype;

use 5.010;
use Moose;
use JSON;

use Jet::Engine::Recipe;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Basetype - Jet Engine Basetype Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engine basetypes.

=head1 ATTRIBUTES

=head3 json

For (de)serializing data

=head3 basetype

The basetype columns

=head3 recipe

The basetype recipe object

=head3 node_role

The role for each node of this basetype

=cut

has 'json' => (
	isa => 'JSON',
	is => 'ro',
	default => sub {
		JSON->new();
	},
	lazy => 1,
);
has basetype => (
	isa => 'HashRef',
	is => 'ro',
);
has recipe => (
	isa => 'Jet::Engine::Recipe',
	is => 'ro',
);
has node_role => (
	isa => 'Moose::Meta::Role',
	is => 'ro',
	default => sub {
		my $self= shift;
		my $role = Moose::Meta::Role->create_anon_role;
		my $colidx;
		for my $column (@{ $self->basetype->{columns} }) {
			$role->add_method( "get_$column", sub {
				my $self = shift;
				my $cols = $self->get_column('columns');
				return $cols->[$colidx++];
			});
		}
		return $role;
	},
	lazy => 1,
);
has engine_role => (
	isa => 'Moose::Meta::Role',
	is => 'ro',
	default => sub {
		my $self= shift;
		my $role = Moose::Meta::Role->create_anon_role;
		my %todo;
		for my $engine ($self->recipe->components_href) {
			while (my ($enginename, $engineval) = each %$engine) {
				while (my ($componentname, $component) = each %$engineval) {
					for my $condition (@{ $component->{conditions} }) {
						my $classname = $condition->{part};
						eval "require $classname" or die $@;

						my $conditionname = $condition->{name} || $classname;
						my $fullname = join '_', $enginename, $componentname, $conditionname;
						my $baseconditions =  {
							%{ $condition->{default} // {} },
							%{ $self->basetype->{conditions}{$fullname} // {} } } //
						{};
						$todo{$fullname} = {
							class => $classname,
							args => $baseconditions,
						};
					}
					for my $step (@{ $component->{steps} }) {
						my $classname = $step->{part};
						eval "require $classname" or die $@;

						my $fullname = join '_', $enginename, $componentname, $classname;
						my $baseargs =  {
							%{ $step->{default} // {} },
							%{ $self->basetype->{steps}{$fullname} // {} } } //
						{};
						$todo{$fullname} = {
							class => $classname,
							args => $baseargs,
						};
					}
				}
			}
		}
		my @components = @{ $self->recipe->components };
		$role->add_method( 'conditions', sub {
			my $self = shift;
			COMPONENT:
			for my $component (@components) {
				my $component_fullname = $component->{fullname};
				for my $condition (@{ $component->{conditions} }) {
					my $conditionname = $condition->{name} || $condition->{part};
					my $fullname = join '_', $component_fullname, $conditionname;
					my $class = $todo{$fullname}{class};
					my $args  = $self->handle_arguments($todo{$fullname}{args});
					my $cond_obj = $class->new(engine => $self, %$args);
					next COMPONENT unless $cond_obj->condition;
				}
				$self->add_component($component);
			}
			return 1;
		});
		$role->add_method( 'parts', sub {
			my $self = shift;
			my @steps;
			for my $component ($self->all_components) {
				my $component_fullname = $component->{fullname};
				for my $step (@{ $component->{steps} }) {
					my $partname = $step->{name} || $step->{part};
					my $fullname = join '_', $component_fullname, $partname;
					my $class = $todo{$fullname}{class};
					my $args  = $todo{$fullname}{args};
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
		});

		$role->add_method( 'handle_arguments', sub  {
			my ($self, $parms) = @_;
			my $stash = $self->stash;
			my $parameters = $self->request->parameters;
			my $args = $self->basenode->arguments;
			while (my ($name, $parm) = each %$parms) {
				if (ref $parm eq 'HASH') {
					$parms->{$name} = $self->replace_argument($parm, $stash, $parameters, $args);
				}
			}
			return $parms;
		});
		$role->add_method( 'replace_argument', sub  {
			my ($self, $parms, $stash, $parameters, $args) = @_;
			my $result;
			while (my ($name, $parm) = each %$parms) {
				$result->{$name} = $self->replace_argument($parm) if (ref $parm eq 'HASH');
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
		});
		return $role;
	},
	lazy => 1,
);

=head1 METHODS

=head2 bind

=cut

sub bind {
}

__PACKAGE__->meta->make_immutable;

1;
__END__

