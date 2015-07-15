package Djet::Trait::Field::Html;

use Moose::Role;
use HTML::FormatText;

=head1 NAME

Djet::Trait::Field::Html - decorate the html field

=cut

=head1 ATTRIBUTES

=head2 formatter

=cut

has 'formatter' => (
	is => 'ro',
	isa => 'HTML::FormatText',
	lazy => 1,
	default => sub { return HTML::FormatText->new },
);

=head1 METHODS

=head2 for_search

Return a value for fts

=cut

sub for_search {
	my $self = shift;
	return $self->value ? $self->formatter->format_from_string($self->value) : $self->value;
}

no Moose::Role;

1;
