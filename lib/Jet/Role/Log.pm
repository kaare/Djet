package Jet::Role::Log;

use 5.010;
use Moose::Role;
use JSON -convert_blessed_universally;

=head1 NAME

Jet::Role::Log - Debug logging made easy

=head1 SYNOPSIS

with 'Jet::Role::Log';

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

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2011 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
