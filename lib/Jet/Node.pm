package Jet::Node;

use 5.010;
use Moose;

use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Node - Represents Jet Nodes

=head1 SYNOPSIS

=head1 ATTRIBUTES

=cut

has row => (
	isa => 'Jet::Engine::Row',
	is => 'ro',
	writer => '_row',
);
has basetype => (
	isa => 'Str',
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return $self->row->get_columns('base_type');
	},
);

=head1 METHODS

=cut

sub add {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';
	for my $column (qw/title part/) {
		return unless defined $args->{$column};
	}

	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $opts = {returning => '*'};
	my $row = $schema->insert($self->basetype, $args, $opts);
	$self->_row($schema->row($row, $self->basetype));
}

sub add_child {
	my ($self, $args) = @_;
	return unless ref $args eq 'HASH';

	for my $column (qw/basetype title part/) {
		return unless ($args->{$column});
	}
# XXX TODO Check that basetype is valid
	my $c = Jet::Context->instance();
	my $schema = $c->schema;
	my $basetype = delete $args->{basetype};
	my $opts = {returning => '*'};
	my $child = $schema->insert($basetype, $args, $opts);
	return $self->new(
		row => $self->_row($schema->row($child, $basetype)),
	);
}

__PACKAGE__->meta->make_immutable;

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
