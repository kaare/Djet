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

						my $fullname = join '_', $enginename, $componentname, $classname;
						my $baseconditions =  {
							%{ $condition->{static} // {} },
							%{ $self->basetype->{conditions}{$fullname} // {} } } //
						{};
						$todo{$fullname} = {
							class => $classname,
							args => $baseconditions,
						};
					}
				}
			}
		}
		my @components = @{ $self->recipe->components };
		$role->add_method( 'conditions', sub {
			my $self = shift;
			for my $component (@components) {
				my $component_fullname = $component->{fullname};
				for my $condition (@{ $component->{conditions} }) {
					my $classname = $condition->{part};
					my $fullname = join '_', $component_fullname, $classname;
					my $class = $todo{$fullname}{class};
					my $args  = $todo{$fullname}{args};
					my $cond_obj = $class->new(engine => $self, %$args);
					$self->add_component($fullname) if $cond_obj->condition;
				}
			}
			return 1;
		});
		$role->add_method( 'parts', sub {
			my $self = shift;
			return 1;
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

