package Jet::Plugin;

use 5.010;
use Moose;

use Jet::Context;

has 'request' => (
	isa => 'Plack::Request',
	is => 'ro',
);
has 'node' => (
	isa => 'Jet::Node',
	is => 'ro',
);

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Jet::Plugin - Jet Plugin Base Class

=head1 SYNOPSIS
