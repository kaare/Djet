package Jet::Failure;

use 5.010;
use Moose;

=head1 NAME

Jet::Failure - Something bad happened to our Jet

=head1 SYNOPSIS

Jet::Failure handles the case when the Jet won't fly


=head1 ATTRIBUTES

=cut

has exception => (
	isa => 'Str|Jet::Exception',
	is => 'ro',
	trigger => sub {
		my ($self, $e) = @_;
		my $stash = $self->stash;
		if (ref $_) {
	# Find Not Found node
	# my $notfound_name = $config->{jet}{nodenames}{notfound};
	# $nodedata = $schema->find_node({ name =>  $notfound_name });
	# my $baserole = $basetypes->{$nodedata->{basetype_id}}->node_role;
	# return $baserole ?
		# Jet::Basenode->with_traits($baserole)->new(%nodeparams, row => $nodedata) :
		# Jet::Basenode->new(%nodeparams, row => $nodedata);
			$stash->{exception} = $e
		} else {
			$stash->{error} = $e
		}
		my $response = $self->response;
		$response->template('generic/error' . $self->config->jet->{template_suffix});
		$response->render;
	},
);
has stash => (
	isa => 'HashRef',
	is => 'ro',
);
has request => (
	isa => 'Jet::Request',
	is => 'ro',
	handles => [qw/
		basetypes
		cache
		config
		schema
	/],
);
has basenode => (
	isa => 'Jet::Basenode',
	is => 'ro',
);
has response => (
	isa => 'Jet::Response',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

1;
__END__

