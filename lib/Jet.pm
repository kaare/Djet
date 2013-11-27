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

=cut

has request => (
	is => 'ro',
	isa => 'Jet::Request',
);

=head1 METHODS

=head2 take_off

Process the request.  Entry point from psgi

=cut

sub take_off {
	my ($self) = @_;
	my $request = $self->request;
	my $schema = $request->schema;
	my $config = $schema->config;
	my $path = $request->request->path_info;
	my $data_nodes = $schema->resultset('DataNode')->find_basenode($path);
	my $basenode = $data_nodes->first;
	$basenode->basetype_id($config->{config}{jet_config}{basetype_id}) if $data_nodes->rest_path eq '_jet_config';

	my $stash = {request => $request};
	my $response = Jet::Response->new(
		stash  => $stash,
		request => $request,
		data_nodes => $data_nodes,
        basenode => $basenode,
	);
	try {
		my $engine_class = $basenode->basetype->class;
		my $engine = $engine_class->new(
			stash => $stash,
			request => $self->request,
			basenode => $basenode,
			response => $response,
		);
		$engine->init;
		$engine->data;
		$engine->set_renderer;
		$engine->render;
	} catch {
		my $e = shift;
		debug($e);
		Jet::Failure->new(
			exception => $e,
			request => $request,
			data_nodes => $data_nodes,
			stash  => $stash,
			response => $response,
		);
	};
	return [ $response->status, $response->headers, $response->output ];
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

# COPYRIGHT

__END__
