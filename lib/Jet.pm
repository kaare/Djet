package Jet;

use 5.010;
package Jet;

use Moose;
use namespace::autoclean;

use Try::Tiny;

use Jet::Failure;
use Jet::Response;

with 'Jet::Role::Log';

# ABSTRACT: A Modern Node-based Content Management System

=head1 NAME

Jet

=head1 DESCRIPTION

Faster than an AWE2

Experimental CMS

=head1 ATTRIBUTES

=head2 body

The body of the jet

=cut

has body => (
	is => 'ro',
	isa => 'Jet::Body',
);

=head2 schema

The schema

=cut

has schema => (
	is => 'ro',
	isa => 'Jet::Schema',
);

=head1 METHODS

=head2 take_off

Process the request.  Entry point from psgi

=cut

sub take_off {
	my ($self) = @_;
	my $body = $self->body;
	my $schema = $self->schema;
	my $config = $schema->config;
	my $path = $body->request->path_info;
	# If the basenode is a directory (ends in "/") we try to see if there is an index.html node for it.
	my $node_path = $path =~ /\/$/ ? $path . "index.html" : $path;
	$schema->log->debug("Node path: $node_path");
	my $datatree = $schema->resultset('Jet::DataNode');
	my $datanodes = $datatree->find_basenode($node_path);
	my $basenode = $datanodes->[0];
	my $rest_path = $datatree->rest_path // '';
	$schema->log->debug('Found node ' . $basenode->name . ' and rest path ' . $rest_path);
	my $engine_class;
	try {
		# See if we want to use the config basetype
		my $engine_basetype = $rest_path eq '_jet_config' ?
			$schema->basetypes->{$config->{config}{jet_config}{basetype_id}} :
			$basenode->basetype;
		$engine_class = $engine_basetype->handler || 'Jet::Engine::Default';
		$schema->log->debug('Class: ' . $engine_basetype->name . ' found, using '. $engine_class);
	} catch {
		my $e = shift;
		die $e if blessed $e && ($e->can('as_psgi') || $e->can('code')); # Leave it to Plack

		debug($e);
		Jet::Failure->new(
			exception => $e,
			body => $body,
			datanodes => $datanodes,
		);
	};
	$body->_set_basenode($basenode);
	$body->_set_datanodes($datanodes);
	$body->_set_rest_path($rest_path);
	return $engine_class;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

# COPYRIGHT

__END__
