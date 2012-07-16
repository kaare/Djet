package Jet::Engine::Condition;

use 5.010;
use Moose;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Condition - Jet Engine Condition Base Class

=head1 SYNOPSIS

Jet::Engine::Condition is the basic building block of all Jet Engine conditions.

In your condition you just write

extends 'Jet::Engine::Condition';

=head1 ATTRIBUTES

=head2 stash

=cut

has 'stash' => (
	isa => 'HashRef',
	is => 'ro',
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

__PACKAGE__->meta->make_immutable;

1;

__END__

