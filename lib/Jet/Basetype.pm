package Jet::Basetype;

use 5.010;
use Moose;
use JSON;

use Jet::Engine::Recipe;
use Jet::Field;

with 'Jet::Role::Log';

=head1 NAME

Jet::Basetype - Jet Basetype Base Class

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
		my $columns = $self->basetype->{columns};
		my @fieldcols;
		for my $column (@{ $columns }) {
			my $colname = $column->{name};
			my $coltype = $column->{type};
			my $traits =  $column->{traits};
			$role->add_attribute("__$colname" => (
				reader  => "get_$colname",
				isa     => 'Jet::Field',
				default => sub {
					my $self = shift;
					my $cols = $self->get_column('columns');
					my %params = (
						value => $cols->[$colidx++],
						title => $colname,
					);
					return $traits ?
						Jet::Field->with_traits(@$traits)->new(%params) :
						Jet::Field->new(%params);
				},
				lazy => 1,
			));
			push @fieldcols, "get_$colname";
		}
		$role->add_attribute('fields' => (
			is => 'ro',
			isa => 'ArrayRef',
			default => sub {
				my $self = shift;
				return [ map {$self->$_} @fieldcols ];
			},
			lazy => 1,
		));
		return $role;
	},
	lazy => 1,
);
has engine_arguments => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self= shift;
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
		return \%todo;
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

