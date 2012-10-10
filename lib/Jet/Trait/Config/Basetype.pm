package Jet::Trait::Config::Basetype;

use 5.010;
use Moose::Role;

=head1 NAME

Jet::Trait::Config::Basetype - Common functionality for parts and conditions

=head1 SYNOPSIS

with 'Jet::Trait::Config::Basetype';

=head1 ATTRIBUTES

=cut

=head1 METHODS

=head2 value

=cut

around value => sub {
	my ($orig, $self) = @_;
	my $node = $self->node;
	my $basetype_id = $node->arguments->[1];
	return $node->basetypes->{$basetype_id}{basetype}{name};
};

=head1 METHODS

=head2 

=cut

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
