package Jet::Trait::Partname;

use 5.010;
use Moose::Role;
use Moose::Util qw( apply_all_roles );
use namespace::autoclean;

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
