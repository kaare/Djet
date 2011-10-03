package Jet::Stuff::QueryBuilder;

use 5.010;
use Moose;

extends 'SQL::Abstract';

__PACKAGE__->meta->make_immutable(inline_constructor => 0);