package Jet::Plugin;

use 5.010;
use Moose;

use Jet::Context;

with 'Jet::Role::Log';

=head1 NAME

Jet::Plugin - Jet Plugin Base Class

=head1 SYNOPSIS

Jet::Plugin is the basic building block of all Jet Plugins.

In your plugin you just write

extends 'Jet::Plugin';

=head1 ATTRIBUTES

=head2 params

=head3 stash variables

Can be scalar, arrayref or hashref

=head4 arrayref

foo => [qw/bar baz/],

Results in a parameter value of

foo => {
	bar => <stash bar value>,
	baz => <stash baz value>,
}

=head3 content variables

=head4 hashref

foo => {
	bar => 'bar',
	baz => 'fooz',
},

Results in a parameter value of

foo => {
	bar => <content bar value>,
	baz => <content fooz value>,
}

=head2 parameters

=cut

has 'params' => (
	isa => 'HashRef',
	is => 'ro',
);
has 'parameters' => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $c = Jet::Context->instance;
		my $stash = $c->stash;
		my $content = $c->rest->content;
		my $vars;
		my $stash_params = $self->params->{stash};
		$vars->{$_} = $self->_parse_params($stash, $_, $stash_params->{$_}) for keys %$stash_params;
		my $content_params = $self->params->{content};
		$vars->{$_} = $self->_parse_params($content, $_, $content_params->{$_}) for keys %$content_params;
		my $static_params = $self->params->{static};
		$vars->{$_} = $static_params->{$_} for keys %$static_params;
		return $vars;
	},
	lazy => 1,
);
has 'node' => (
	isa => 'Jet::Node',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $c = Jet::Context->instance;
		return $c->node;
	},
	lazy => 1,
);
has 'stash' => (
	isa => 'HashRef',
	is => 'ro',
	default => sub {
		my $self = shift;
		my $c = Jet::Context->instance;
		return $c->stash;
	},
	lazy => 1,
);

sub _parse_params {
	my ($self, $container, $key, $params) = @_;
	given (ref $params) {
		when ('') {
			return $container->{$key};
		}
		when ('HASH') {
			my $var;
			$var->{$_} = $container->{$params->{$_}} for keys %$params;
			return $var;
		}
		when ('ARRAY') {
			my $var;
			$var->{$_} = $container->{$_} for @$params;
			return $var;
		}
	}
}

__PACKAGE__->meta->make_immutable;

1;
__END__

