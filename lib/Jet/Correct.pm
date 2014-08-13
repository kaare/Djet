package Jet::Correct;

use 5.010;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

with 'Jet::Role::Basic';

=head1 NAME

Jet::Correct

=head1 DESCRIPTION

Jet::Correct is a base class for default_class, or correction classes.

The purpose of this is to have a class that always is executed for any node.

=head1 ATTRIBUTES

=head2 content_type

=cut

has 'content_type' => (
	is => 'ro',
	isa => 'Str',
);

=head1 METHODS

Only two methods are implemented.

=head2 before

Is called before init_data in the engine classes

=cut

sub before {}

=head2 after

Is called after the data, but before render in the engine classes

=cut

sub after {}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

