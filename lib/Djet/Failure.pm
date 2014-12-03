package Djet::Failure;

use 5.010;
use Moose;
use namespace::autoclean;

use Djet::Exception;

=head1 NAME

Djet::Failure - Something bad happened to our Jet

=head1 SYNOPSIS

Djet::Failure handles the case when the Jet crashes

=head1 ATTRIBUTES

=cut

has exception => (
	isa => 'Str|Djet::Exception',
	is => 'ro',
	trigger => sub {
		my ($self, $e) = @_;
		my $stash = $self->stash;
		if (ref $_) {
	# Find Not Found node
	# my $notfound_name = $config->{djet}{nodenames}{notfound};
	# $nodedata = $schema->find_node({ name =>  $notfound_name });
	# my $baserole = $basetypes->{$nodedata->{basetype_id}}->node_role;
	# return $baserole ?
		# Djet::Basenode->with_traits($baserole)->new(%nodeparams, row => $nodedata) :
		# Djet::Basenode->new(%nodeparams, row => $nodedata);
			$stash->{exception} = $e
		} else {
			$stash->{error} = $e
		}
		my $response = $self->response;
		$response->template('generic/error' . $self->config->config->{template_suffix});
		$response->render;
	},
);
has stash => (
	isa => 'HashRef',
	is => 'ro',
);
has body => (
	isa => 'Djet::Body',
	is => 'ro',
	handles => [qw/
		basetypes
		cache
		config
		schema
	/],
);
has basenode => (
	isa => 'Djet::Schema::Result::Djet::DataNode',
	is => 'ro',
);
has response => (
	isa => 'Djet::Response',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

1;

# COPYRIGHT

__END__

