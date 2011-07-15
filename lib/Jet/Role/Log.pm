package Jet::Role::Log;

use 5.010;
use Moose::Role;
use JSON;

sub trace {
	my $self = shift;
	my @package;
	my $level = 0;
	while (my ($package, $filename, $line, $sub, $hasargs, $wantarray, $evaltext, $is_require) = caller($level++)) {
		last unless $package || $sub ne "(eval)";

		push @package, "$level: $package, Sub: $sub, file: $filename, line: $line";
	}
	print STDERR JSON->new->allow_blessed->pretty->encode({stack => \@package, values => \@_} );
}

sub debug {
	my $self = shift;
	my($package, $filename, $line) = caller;
	print STDERR JSON->new->allow_blessed->pretty->encode({package => $package, file => $filename, line => $line, values => \@_ });
}

no Moose::Role;

1;
