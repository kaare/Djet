package Jet::Part;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Part - Base classe for Jet::Parts

=head1 SYNOPSIS

with 'Jet::Part';

=cut

requires qw/stash request basenode response/;

no Moose::Role;

sub init {}
sub data {}
sub render {}

1;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2013 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
