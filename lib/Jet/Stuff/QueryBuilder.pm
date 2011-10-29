package Jet::Stuff::QueryBuilder;

use 5.010;
use Moose;

extends 'SQL::Abstract';

=head1 NAME

Jet::Stuff::QueryBuilder - Build database queries

=head1 DESCRIPTION

Helps in building SQL queries

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

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
