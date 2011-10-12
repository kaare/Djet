package Jet::Engine::Test;

use 5.010;
use Moose;

extends 'Jet::Engine';

use Data::Dumper;
sub BUILD {
	my $self = shift;
	$self->stash->{x} = 1;
	say __PACKAGE__;
}

__PACKAGE__->meta->make_immutable;
1;
__END__
=head1 NAME

Jet::Engine - Jet Engine Base Class

=head1 SYNOPSIS
