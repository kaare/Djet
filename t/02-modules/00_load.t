use 5.010;
use strict;
use warnings;
use Test::More;
use File::Find;

my @dirs = qw/lib/;
my @modules;
find(\&wanted, @dirs);

for my $module (@modules) {
	use_ok($module);
	next if $module =~ /Role/ || $module =~ /^Djet::[Part|Schema|Body|Trait::Field::Price]/;

	ok(my $new = $module->new, "New $module object");
}

done_testing;

sub wanted {
	return unless $File::Find::name =~ m|lib/(.+)\.pm$|;

	my $name = $1;
	$name =~ s|/|::|g;
	push @modules, $name;
}
