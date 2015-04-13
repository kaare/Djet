package Djet::Part::Dispatcher;

use 5.010;

use List::Util qw/any/;

use MooseX::Role::Parameterized;
use namespace::autoclean;

=head1 NAME

Djet::Part::Dispatcher - Dispatch to methods based on the rest_path

=head1 SYNOPSIS

with 'Djet::Part::Dispatcher';

=head1 DESCRIPTION

A common pattern is to pass an action as a parameter to a node. To distinquish between several methods, and to make sure they
only fire if they are allowed, use this role.

=head1 PARAMETERS

=head2 modify

An arrayref with the methods we allow to modify. Can be to_html, to_json.

=cut

parameter 'modify' => (
	isa => 'ArrayRef',
	default => sub { [qw/to_html to_json/] },
	lazy => 1,
);

=head2 methods

An arrayref with the methods we allow to dispatch to.

=cut

parameter 'methods' => (
	isa => 'ArrayRef',
);

=head1 ROLE

=cut

role {
	my $params = shift;

	before $params->modify => sub {
		my $self = shift;
		my $model = $self->model;
		my $rest_path = $model->rest_path;
		return unless any {$rest_path eq $_} @{ $params->methods };

warn "Dispatch to $rest_path";
		return $self->$rest_path;
	};
};

no Moose::Role;

1;

# COPYRIGHT

__END__
