package Jet::Engine::Node::FTS;

use 5.010;
use Moose;
use File::Copy;
use File::Path;

extends 'Jet::Engine';

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Node::FTS - FullText Search


=head1 SYNOPSIS

=head1 METHODS

=head2 data

Search nodes using PostgreSQL's fts

=head1 PARAMETERS

=cut

sub data {
	my $self = shift;
	my $parms = $self->parameters;
	my $words = $parms->{words};
debug($words);
	my $c = Jet::Context->instance();
	$c->schema->ft_search_nodepath($words)
}

no Moose::Role;

1;

=head1 AUTHOR

Kaare Rasmussen, <kaare at cpan dot com>

=head1 BUGS

Please report any bugs or feature requests to my email address listed above.

=head1 COPYRIGHT & LICENSE

Copyright 2012 Kaare Rasmussen, all rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may
have available.
