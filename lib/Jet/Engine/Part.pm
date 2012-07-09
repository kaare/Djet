package Jet::Engine::Part;

use 5.010;
use Moose;

with 'Jet::Role::Log';

=head1 NAME

Jet::Engine::Part - Jet Engine Part Base Class

=head1 SYNOPSIS

Jet::Engine is the basic building block of all Jet Engine parts.

In your engine you just write

extends 'Jet::Engine::Part';

=head1 ATTRIBUTES

=head1 METHODS

=head2 title

Provides the human readable title

=cut

sub title {
	return 'Not Yet Implemented'; 
}

=head2 parameter_names

Returns an arrayref with the names of the part's parameters

=cut

sub parameter_names {
	my ($self) = @_;
	my $meta = $self->meta;
	my @names;
	push @names, $_->name for $meta->get_all_attributes;
	return \@names;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

