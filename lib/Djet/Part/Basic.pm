package Djet::Part::Basic;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Basic

=head1 DESCRIPTION

The basic attributes for Djet classes.

=head1 ATTRIBUTES

=head2 model

The Djet model. The model extends L<Djet::Schema>, but there are also accessors for configuration, basetypes, renderers and log

This is a reference back to the main model, so it's weakened.

=cut

has model => (
	is => 'ro',
	isa => 'Djet::Model',
	handles => [qw/
		acl
		basetypes
		config
		log
		renderers
	/],
	weak_ref => 1,
);
no Moose::Role;

1;

# COPYRIGHT

__END__
