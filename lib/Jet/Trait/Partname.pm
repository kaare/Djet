package Jet::Trait::Partname;

use 5.010;
use Moose::Role;
use Moose::Util qw( apply_all_roles );
use namespace::autoclean;

=head1 NAME

Jet::Trait::Partname - Trait for the engine parts

=head1 SYNOPSIS

In your engine you just write

extends 'Jet::Engine';

... and define the parts

has parts => (
	traits	=> [qw/Jet::Trait::Partname/],
	is		=> 'ro',
	isa	   => 'ArrayRef',
	parts => [
		{'Jet::Part::Basenode' => 'jet_basenode'},
		{
			module => 'Jet::Part::Children',
			alias  => 'jet_children',
			type => 'json',
		},
	],
);

=head1 DESCRIPTION

Jet::Engine is the basic building block of all Jet Engines.

=head1 ATTRIBUTES

=head2 parts

An arrayref with the engine parts.

Each part is either a

=over 4

=item * simple hashref with the module name as a key and the alias as the value

=item * hashref with the keys module, alias, and type (media type)

=back

=cut

has parts => (
	is => 'ro',
	isa => 'ArrayRef',
);

after 'attach_to_class' => sub {
	my ($attr, $class) = @_;
	my @parts = @{ $attr->parts // [] };
	my @aliases;
	foreach my $part (@parts) {
		my ($module, $alias, $type);
		if ((my @keys = keys %$part) == 1) {
			$module = $keys[0];
			$alias = $part->{$module};
		} else {
			$module = $part->{module};
			$alias = $part->{alias};
			$type = $part->{type};
		}
		my @phases = qw/init data render/;
		my %aliases = map {$_ => $alias . '_' . $_} @phases;
		apply_all_roles($class, $module, {-alias => \%aliases, -excludes => \@phases},);
		push @aliases, $alias;
	}
	for my $phase (qw/_init _data _render/) {
		$class->add_method($phase, sub {
			return map {
				$_ . $phase;
			} @aliases;
		});
	}
};

no Moose::Role;

1;

# COPYRIGHT

__END__
