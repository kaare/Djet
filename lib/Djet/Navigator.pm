package Djet::Navigator;

use 5.010;
use Moose;
use namespace::autoclean;

use Try::Tiny;
use List::Util qw/first/;

use Djet::Failure;
use Djet::Response;

with qw/
	Djet::Part::Generic::Urify
/;

=head1 NAME

Djet::Navigator

=head1 DESCRIPTION

Attributes and methods to navigate the World.

=head1 ATTRIBUTES

=head2 request

The request

=cut

has request => (
	is => 'ro',
	isa => 'Plack::Request',
);

=head2 session

The session

=cut

has session => (
	is => 'ro',
	isa => 'HashRef',
);

=head2 schema

The schema

=cut

has model => (
	is => 'ro',
	isa => 'Djet::Model',
);

=head2 basenode

The node we're working on

=cut

has basenode => (
	isa => 'Djet::Schema::Result::Djet::DataNode',
	is => 'ro',
	writer => '_set_basenode',
);

=head2 datanodes

The node stack found

=cut

has datanodes => (
	isa => 'ArrayRef[Djet::Schema::Result::Djet::DataNode]',
	is => 'ro',
	writer => '_set_datanodes',
);

=head2 rest_path

The remaining part after the basenode has been found.

=cut

has rest_path => (
	 is => 'ro',
	 isa => 'Str',
	 default => sub {
		 my $self = shift;
		 my $raw = $self->raw_rest_path or return '';

		 $raw =~ s/^index.html$//;
		 return $raw;
	 },
	 lazy => 1,
);

=head2 raw_rest_path

The raw remaining part after the basenode has been found.

=cut

has raw_rest_path => (
	 is => 'ro',
	 isa => 'Str',
	 writer => 'set_raw_rest_path',
);

=head2 result

If there is a plack result from the navigator, it's here.

=cut

has result => (
	 is => 'ro',
	 isa => 'ArrayRef',
	 writer => 'set_result',
	 predicate => 'has_result',
);

=head1 METHODS

=head2 find_basenode

Find the basenode

Returns a set of rows as an arrayref, starting from the basenode and with the root last.

Thus, we're sure always to have to whole branch, and we can also find the arguments of the request

As a side effect this method sets raw_rest_path.

=cut

sub find_basenode {
	my ($self, $path) = @_;
	my $model = $self->model;
	my @datanodes = $model->resultset('Djet::DataNode')->search({node_path => { '@>' => $path } }, {order_by => \'length(node_path) DESC' })->all;
	my $basenode = $datanodes[0] or return;

	my $base_path = quotemeta $basenode->node_path;
	if ( $path =~ m|^$base_path/(.*)|) {
		$self->set_raw_rest_path($1);
	}
	return \@datanodes;
}

=head2 check_route

Check if we can find the way

First it looks for the path itself. Then it checks if the user is allowed access. If not, a redirect is issued.

If no redirect is issued, the attributes 

  basenode
  datanodes
  raw_rest_path and
  rest_path

are all set.

=cut

sub check_route {
	my $self = shift;
	my $model = $self->model;
	my $config = $model->config;
	my $path = $self->request->path_info;
	$model->log->debug("Node path: $path");
	my $datanodes = $self->find_basenode($path);
	my $basenode = $datanodes->[0];
	$self->_set_datanodes($datanodes);
	return if $self->check_node_redirect($basenode);

	return $self->login($datanodes, $config, $path) unless my $user = $model->acl->check_login($self->session, $datanodes);

	$model->log->debug("Acting as $user");
	$self->_set_basenode($basenode);

	my $rest_path = $self->rest_path;
	$model->log->debug('Found node ' . $basenode->name . ' and rest path ' . $rest_path);
}

=head2 check_node_redirect

Check if the node has a redirect attribute. If it does, set the result accordingly.

Redirections can be avoided by setting the noredirect parameter.

=cut

sub check_node_redirect {
	my ($self, $basenode) = @_;
	return unless first {$_ eq 'redirect'} @ { $basenode->nodedata->fieldnames };
	return unless my $redirect = $basenode->nodedata->redirect;
	return if $self->request->parameters->{noredirect};

	my $uri = $self->urify({node => $basenode, path => $redirect});
	return $self->set_result([ 302, [ Location => $uri ], [] ]);
}

=head2 login

Redirect to the login page

If there is a login node in the current domain, it will be used. Otherwise, any login node (there's probably only one) is used.

=cut

sub login {
	my ($self, $datanodes, $config, $original_path) = @_;
	$self->session->{redirect_uri} = $original_path;

	my $login_basetype = $self->model->basetype_by_name('login') or return;

	my $domain_basetype = $self->model->basetype_by_name('domain');
	my $domain_node = $self->datanode_by_basetype($domain_basetype);
	my $find = {
		basetype_id => $login_basetype->id,
		node_path => {'<@' => [$domain_node->node_path, '/']},
	};
	my $options = {
		order_by => \'length(node_path)',
		rows => 1,
	};
	my $login_node = $self->model->resultset('Djet::DataNode')->find($find, $options) or return;

	my $uri = $self->urify($login_node, $domain_node);
	$self->set_result([ 302, [ Location => $uri ], [] ]);
	return;
}

=head2 datanode_by_basetype

returns the first node from the datanodes, given a basetype or a basetype id

=cut

sub datanode_by_basetype {
	my ($self, $basetype) = @_;
	my $basetype_id = ref $basetype ? $basetype->id : $basetype;
	return first {$_->basetype_id == $basetype_id} @ { $self->datanodes };
}

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__

