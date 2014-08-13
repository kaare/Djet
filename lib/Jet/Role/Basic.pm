package Jet::Role::Basic;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Jet::Role::Basic

=head1 DESCRIPTION

The basic attributes for Jet classes.

=head1 ATTRIBUTES

=head2 schema

The Jet schema. For easy access, it also contains the config, basetypes, renderers and log

=cut

has schema => (
	is => 'ro',
	isa => 'Jet::Schema',
	handles => [qw/
		config
		basetypes
		renderers
		log
	/],
);

=head2 body

The Jet body. Contains the stash and basenode

=cut

has body => (
	is => 'ro',
	isa => 'Jet::Body',
	handles => [qw/
		stash
		basenode
		datanodes
	/],
);

no Moose::Role;

1;

# COPYRIGHT

__END__
