package Jet::Role::Engine::Part;

use 5.010;
use Moose::Role;

=head1 NAME

Jet::Role::Engine::Part - Common functionality for parts and conditions

=head1 SYNOPSIS

with 'Jet::Role::Engine::Part';

=head1 ATTRIBUTES

=head2 engine

The engine contains all the information needed,

	cache
	config
	parameters
	request
	response
	schema
	stash

=cut

has 'engine' => (
	isa => 'Jet::Engine',
	is => 'ro',
	handles => [qw( cache config parameters request response schema stash )],
);

=head1 METHODS

=head2 attribute_names

Returns an arrayref with the names of the part's attributes

=cut

sub attribute_names {
	my ($self) = @_;
	my $meta = $self->meta;
	my @names;
	push @names, $_->name for $meta->get_all_attributes;
	return \@names;
}

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
