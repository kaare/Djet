package Djet::Part::Basic;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Basic

=head1 DESCRIPTION

The basic attributes for Djet classes.

=head1 ATTRIBUTES

=head2 schema

The Djet schema. For easy access, it also contains the config, basetypes, renderers and log

=cut

has schema => (
	is => 'ro',
	isa => 'Djet::Schema',
	handles => [qw/
		acl
		basetypes
		config
		log
		renderers
	/],
);

=head2 body

The Djet body. Contains the stash and basenode

=cut

has body => (
	is => 'ro',
	isa => 'Djet::Body',
	handles => [qw/
		basenode
		datanode_by_basetype
		datanodes
		request
		rest_path
		session
		session_id
		stash
	/],
);

no Moose::Role;

1;

# COPYRIGHT

__END__
