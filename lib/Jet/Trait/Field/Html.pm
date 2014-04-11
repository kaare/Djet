package Jet::Trait::Field::Html;

use Moose::Role;
use HTML::FormatText;

=head1 NAME

Jet::Trait::Field::Html - decorate the html field

=cut

requires qw/value/;

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
	return $self->formatter->format_from_string($self->value)
}

1;
