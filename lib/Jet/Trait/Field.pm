package Jet::Trait::Field;

use 5.010;
use Moose::Role;

=head1 NAME

Jet::Trait::Field - Attributes and feature for Jet Fields

=head1 ATTRIBUTES

=head2 title

The field's title

=cut

has title => (
	is => 'ro',
	isa => 'Str',
);

no Moose::Role;

1;

__END__

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS 

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE 

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as 
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may 
have available.
