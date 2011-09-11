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
		$vars->{$_} = $stash->{$stash_params->{$_}} for keys %$stash_params;
		my $content_params = $self->params->{content};
		$vars->{$_} = $content->{$content_params->{$_}} for keys %$content_params;
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

__PACKAGE__->meta->make_immutable;

1;
__END__

