package Djet::Part::Basic;

use 5.010;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Djet::Part::Basic

=head1 DESCRIPTION

The basic attributes for Djet classes.

=head1 ATTRIBUTES

There are two attributes. The one following the server process, model. And the one following the request, body.

=head2 model

The Djet model. The model extends L<Djet::Schema>, but there are also accessors for configuration, basetypes, renderers and log

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
