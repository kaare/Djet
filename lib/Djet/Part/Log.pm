package Djet::Part::Log;

use 5.010;
use Moose::Role;
use namespace::autoclean;

use JSON -convert_blessed_universally;

=head1 NAME

Djet::Part::Log - Debug logging made easy

=head1 SYNOPSIS

with 'Djet::Part::Log';

=head1 METHODS

=head2 trace

Prints a trace stack on STDERR

=head2 debug

Debugs to STDERR

=cut

sub trace {
	my @package;
	my $level = 0;
	while (my ($package, $filename, $line, $sub, $hasargs, $wantarray, $evaltext, $is_require) = caller($level++)) {
		last unless $package || $sub ne "(eval)";

		push @package, "$level: $package, Sub: $sub, file: $filename, line: $line";
	}
	print STDERR JSON->new->allow_blessed->convert_blessed->pretty->encode({stack => \@package, values => \@_} );
}

sub debug {
	my($package, $filename, $line) = caller;
	print STDERR JSON->new->allow_blessed->convert_blessed->pretty->encode({package => $package, file => $filename, line => $line, values => \@_ });
}

no Moose::Role;

1;

# COPYRIGHT

__END__
