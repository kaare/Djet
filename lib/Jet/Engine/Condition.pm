package Jet::Engine::Condition;

use 5.010;
use Moose;

with qw/Jet::Role::Log Jet::Role::Engine::Part/;

=head1 NAME

Jet::Engine::Condition - Jet Engine Condition Base Class

=head1 SYNOPSIS

Jet::Engine::Condition is the basic building block of all Jet Engine conditions.

In your condition you just write

extends 'Jet::Engine::Condition';

=cut

__PACKAGE__->meta->make_immutable;

1;

__END__

