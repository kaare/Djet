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
	foreach my $part (@parts) {
		my $partname = [keys %$part]->[0];
		my $alias = $part->{$partname};
		my @phases = qw/init data render/;
		my %aliases = map {$_ => $alias . '_' . $_} @phases;
		apply_all_roles($class, $partname, {-alias => \%aliases, -excludes => \@phases},);
	}
	for my $phase (qw/_init _data _render/) {
		$class->add_method($phase, sub {
			return map {
				my $partname = [values %$_]->[0];
				$partname . $phase;
			} @parts
		});
	}
};

no Moose::Role;

1;
